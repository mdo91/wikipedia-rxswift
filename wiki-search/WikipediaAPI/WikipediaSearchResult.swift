//
//  WikipediaSearchResult.swift
//  wiki-search
//
//  Created by Mdo on 27/07/2021.
//

import Foundation
import RxSwift

struct WikipediaSearchResult:CustomDebugStringConvertible{
    
    let title:String
    let description:String
    let URL:Foundation.URL
    
    static func parseJSON(_ json:[AnyObject]) throws -> [WikipediaSearchResult]{
        
        let rootArrayTyped = json.compactMap({$0 as? [AnyObject]})
        
    //    print("WikipediaSearchResult.parseJSON.rootArrayTyped\(rootArrayTyped)")
        
        guard rootArrayTyped.count == 3 else{
            throw wikipediaParseError
        }
        
        let (titles,descriptions,urls) = (rootArrayTyped[0],rootArrayTyped[1],rootArrayTyped[2])
        
        let titleDescriptionAndUrl: [((AnyObject,AnyObject),AnyObject)] = Array(zip(zip(titles,descriptions),urls))
        
        return try titleDescriptionAndUrl.map({ (result) -> WikipediaSearchResult in
            
            let ((title,description),url) = result
            
            guard let titleString = title as? String,
                  let descriptionString = description as? String,
                  let urlString = url as? String,
                  let URL = Foundation.URL(string: urlString) else {
                throw wikipediaParseError
            }
            
            return WikipediaSearchResult(title: titleString, description: descriptionString, URL: URL)
        })
        
    }
}
extension WikipediaSearchResult{
    
    var debugDescription: String{
        "[\(title)(\(URL))]"
    }
}
