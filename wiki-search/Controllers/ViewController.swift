//
//  ViewController.swift
//  wiki-search
//
//  Created by Mdo on 23/07/2021.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {
    
    
    //MARK: - properties
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var emptyView: UILabel!
    
 
    
    let disposeBag = DisposeBag()
    let `$`  = Dependencies.sharedDependencies
    private var imageCache = NSCache<AnyObject,AnyObject>()
    let loadingImage = ActivityIndicator()
   
    
    
    //life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.edgesForExtendedLayout = .all
        
        configureTableViewDataSource()
        configureKeyboardDissmessesOnScroll()
        configureActivityIndicatorShow()
        configureNavigationOnRowClick()
       // let decodedImage : Observable<Image>

        
        let result =  URLSession.shared.rx.data(request: URLRequest(url: URL(string: "http://upload.wikimedia.org/wikipedia/commons/8/8a/Kit_body_realmadrid2021h.png")!))
            .do(onNext: {
                data in
                
                print("data mdo \(data)")
            },onError: { (error) in
                print("on error\(error)")
            })
            .flatMap(self.decodeImage)
            .trackActivity(self.loadingImage)
        
        result.asDriver(onErrorJustReturn: UIImage())
            .drive(UIImageView().rx.image)
        .disposed(by: disposeBag)
//      _ =  decodedImage.do(onNext: {
//            image in
//
//            print("image data \(image)")
//        })
        
            
        
      //  self.resultsTableView.rx.items
        
    }
    
    
    private func decodeImage(_ imageData:Data) -> Observable<Image>{
        
        return Observable.just(imageData)
            
            .observeOn(MainScheduler.instance)
            .map{ data in
                
                guard let image = Image(data: data) else{
                    throw apiError("Error during parsing")
                }
                return image.forceLazyDecomperssion()
                
            }
    }
    
    func configureTableViewDataSource(){
        
        //WikipediaSearchCell
        //WikipediaImageCell
        
        tableView.register(UINib(nibName: "WikipediaSearchCell", bundle: nil), forCellReuseIdentifier: "WikipediaSearchCell")
        
        tableView.rowHeight = 194
        tableView.hideEmptyCells()
        let API = DefaultWikipediaAPI.sharedAPI
        
        let resutls = searchBar.rx.text.orEmpty
            .asDriver()
            .throttle(.milliseconds(300))
            .distinctUntilChanged()
            .flatMapLatest { query in
                
               // guard self = self else{ return}
                
                    API.getSearchResults(query)
                    .retry(3)
                    .retryOnBecomesReachable([], reachabilityService:Dependencies.sharedDependencies.reacabilityService)
                    .startWith([]) // clears search results for new term
                    .asDriver(onErrorJustReturn:[])

                
        
      //  resultsTableView.hide
            }
            .map{
                results in
                results.map(SearchResultViewModel.init)
            }
        resutls
            .drive(tableView.rx.items(cellIdentifier: "WikipediaSearchCell", cellType:WikipediaSearchCell.self )){ (_, viewModel,cell) in
                
                cell.viewModel = viewModel
                
            }
            .disposed(by: disposeBag)
        
        resutls
            .map({$0.count != 0})
            .drive(self.emptyView.rx.isHidden)
            .disposed(by: disposeBag)
        

        
     

        
    }
    
    func configureKeyboardDissmessesOnScroll(){
        let searchBar = self.searchBar
        
        self.tableView.rx.contentOffset
            .asDriver()
            .drive(onNext: { _ in
                if searchBar?.isFirstResponder ?? false{
                    _ = searchBar?.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func configureNavigationOnRowClick(){
        
        let wireFrame = DefaultWireFrame.shared
        
        tableView.rx.modelSelected(SearchResultViewModel.self)
            .asDriver()
            .drive(onNext: {
                searchResult in
                
                wireFrame.open(url: searchResult.searchResult.URL)
            })
            .disposed(by: disposeBag)
        
    }
    
    func configureActivityIndicatorShow(){
        Driver.combineLatest(DefaultWikipediaAPI.sharedAPI.loadingWikipediaData, DefaultImageService.sharedImageService.loadingImage)
            { $0 || $1
            
        }.distinctUntilChanged()
        .drive(UIApplication.shared.rx.isNetworkActivityIndicatorVisible)
        .disposed(by: disposeBag)
    }


}


