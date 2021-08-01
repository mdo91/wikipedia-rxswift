//
//  SearchResultViewModel.swift
//  wiki-search
//
//  Created by Mdo on 27/07/2021.
//

import Foundation
import RxCocoa
import RxSwift

class SearchResultViewModel{
    
    let searchResult:WikipediaSearchResult
    
    var title:Driver<String>
    var imageURLs:Driver<[URL]>
    
    let API = DefaultWikipediaAPI.sharedAPI
    let `$`:Dependencies = Dependencies.sharedDependencies
    
    init(searchResult:WikipediaSearchResult) {
        self.searchResult = searchResult
        self.title = Driver.never()
        self.imageURLs = Driver.never()
        
        let URLs = configureImageURLs()
        
        self.imageURLs = URLs.asDriver(onErrorJustReturn:[])
        self.title = configureTitle(URLs).asDriver(onErrorJustReturn: "Error during fetching")
    }
    
    //private methods
    
    func configureTitle(_ imageURLs:Observable<[URL]>) -> Observable<String>{
        let searchResult = self.searchResult
        
        let loadingValue: [URL]? = nil
        
        return imageURLs
            .map(Optional.init)
            .startWith(loadingValue)
            .map{ URLs in
                
                if let URLs = URLs{
                    return "\(searchResult.title) (\(URLs.count) pictures)"
                }else{
                    return "\(searchResult.title) (loading..)"
                }
            }
            .retryOnBecomesReachable("⚠️ Service offline ⚠️", reachabilityService: `$`.reacabilityService)
    }
    
    func configureImageURLs()->Observable<[URL]>{
        
        let searchResult = self.searchResult
        return API.articleContent(searchResult)
            .observeOn(`$`.backgroundWokrSchedular)
            .map{
                page in
                do{
             //       print("configureImageURLs.\( try parseImageURLsfromHTMLSuitableForDisplay(page.text as NSString))")
                    return try parseImageURLsfromHTMLSuitableForDisplay(page.text as NSString)
                }catch{
                    return []
                }
            }
            .share(replay: 1)
    }
    
}
