//
//  UIImage+Extensions.swift
//  wiki-search
//
//  Created by Mdo on 27/07/2021.
//

import Foundation
import UIKit

extension Image{
    
    func forceLazyDecomperssion() -> Image {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        self.draw(at: CGPoint.zero)
        UIGraphicsEndImageContext()
        return self
    }
}
