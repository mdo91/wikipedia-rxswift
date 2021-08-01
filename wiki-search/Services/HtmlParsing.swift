//
//  HtmlParsing.swift
//  wiki-search
//
//  Created by Mdo on 27/07/2021.
//

import Foundation


func parseImageURLsfromHTML(_ html:NSString) throws -> [URL]{
    
    let regularExpression = try NSRegularExpression(pattern: "<img[^>]*src=\"([^\"]+)\"[^>]*>", options: [])
    
    let matches = regularExpression.matches(in: html as String, options: [], range: NSMakeRange(0, html.length))
    
    return matches.map { match -> URL? in
        
    //    print("parseImageURLsfromHTML.match \(match) numberOfRanges:\(match.numberOfRanges) ")
        if match.numberOfRanges != 2{
            return nil
        }
        
        let url = html.substring(with: match.range(at:1))
        var absolueURLString = url
        
        if url.hasPrefix("//"){
            absolueURLString = "http:" + url
        }
        
        return URL(string: absolueURLString)
        
    }
    .filter { $0 != nil}
    .map{ $0!}
    
}

func parseImageURLsfromHTMLSuitableForDisplay(_ html:NSString) throws -> [URL]{
    
    return try parseImageURLsfromHTML(html).filter({
        $0.absoluteString.range(of: ".svg.") ==  nil
    })
}
