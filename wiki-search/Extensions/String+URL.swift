//
//  String+URL.swift
//  wiki-search
//
//  Created by Mdo on 27/07/2021.
//

import Foundation

extension String{
    
    var URLEscaped:String{
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
