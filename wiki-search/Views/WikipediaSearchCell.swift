//
//  WikipediaSearchCell.swift
//  wiki-search
//
//  Created by Mdo on 23/07/2021.
//

import UIKit
import RxSwift
import RxCocoa

class WikipediaSearchCell: UITableViewCell {
    

    //MARK: - properties & outlets
    
    @IBOutlet var titleOutlet:UILabel!
    @IBOutlet var URLOutlet:UILabel!
    @IBOutlet var imageOutLet:UICollectionView!
    
    var disposeBag:DisposeBag?
    let imageService = DefaultImageService.sharedImageService

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imageOutLet.register(UINib(nibName: "WikipediaImageCell", bundle: nil), forCellWithReuseIdentifier: "ImageCell")
    }
    
    var viewModel:SearchResultViewModel?{
        
        didSet{
            let disposeBag = DisposeBag()
            
            guard let viewModel = viewModel else{
                return
            }
            
            viewModel.title
                .map(Optional.init)
                .drive(self.titleOutlet.rx.text)
                .disposed(by: disposeBag)
            
            self.URLOutlet.text = viewModel.searchResult.URL.absoluteString
            
            let reachabilityService  = Dependencies.sharedDependencies.reacabilityService
           
            
            viewModel.imageURLs
                .drive(self.imageOutLet.rx.items(cellIdentifier: "ImageCell", cellType: WikipediaImageCell.self)){ [weak self] (_,url,cell) in
               
                    cell.downloadableImage = self?.imageService.imageFromURL(url, reachabilityService: reachabilityService) ??
                        Observable.empty()
                    
                }
                .disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
            
            #if DEBUG
          //  self.installHackBecauseOfAutomationLeaksOnIOS10(firstViewThatDoesNotLeak: self.superview!.superview!)
            #endif
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.viewModel = nil
        self.disposeBag = nil
    }
    
    deinit {
        
    }
    


}
private protocol ReusableView:AnyObject{
    var disposeBag: DisposeBag? {get}
    func prepareForReuse()
}

extension WikipediaImageCell:ReusableView{
    
}
extension WikipediaSearchCell:ReusableView{
    
}

private extension ReusableView{
    
    func installHackBecauseOfAutomationLeaksOnIOS10(firstViewThatDoesNotLeak:UIView){
        if #available(iOS 10.0, *){
            if UIApplication.isUnitTest{
                firstViewThatDoesNotLeak.rx.deallocated.subscribe(onNext:{
                    [weak self] _ in
                    
                    self?.prepareForReuse()
                })
                .disposed(by: self.disposeBag!)
            }
            
        }
    }
}

extension UIApplication{
    
    static var isUnitTest:Bool{
        ProcessInfo.processInfo.environment["IsUITest"] != nil
    }
}
