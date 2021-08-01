//
//  UITableView+Extension.swift
//  wiki-search
//
//  Created by Mdo on 29/07/2021.
//

import Foundation
import UIKit


extension UITableView{
    
    func hideEmptyCells(){
        self.tableFooterView = UIView(frame: .zero)
    }
}
