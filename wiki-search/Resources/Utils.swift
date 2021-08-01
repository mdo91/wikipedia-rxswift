//
//  Utils.swift
//  wiki-search
//
//  Created by Mdo on 23/07/2021.
//

import Foundation
import UIKit

let MB = 1024 * 1024

func exampleError(_ error:String,location:String = "\(#file):\(#line)")-> NSError{
    
    return NSError(domain: "ExampleError", code: -1, userInfo: [NSLocalizedDescriptionKey : "\(location): \(error)"])
    
}

extension String{
    
    func ToFloat() -> Float?{
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.floatValue
    }
    
    func toDouble()-> Double?{
        let numberFormatter = NumberFormatter()
        return numberFormatter.number(from: self)?.doubleValue
    }
}
