//
//  Wireframe.swift
//  wiki-search
//
//  Created by Mdo on 26/07/2021.
//

import Foundation
import RxSwift
import UIKit


enum RetyResult{
    
    case retry
    case cancel
}

protocol Wireframe {
    func open(url:URL)
    func promptFor<Action:CustomStringConvertible>(_ message:String,cancelAction:Action, actions:[Action]) -> Observable<Action>
}
class DefaultWireFrame:Wireframe{
    
    
    func open(url: URL) {
        UIApplication.shared.open(url)
    }
    
    private static func rootViewController() -> UIViewController{
        return UIApplication.shared.keyWindow!.rootViewController!
    }
    
    static func presentAlert(_ message:String){
        
        let alertView = UIAlertController(title: "WikiSearch", message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in
            
        }))
        
        rootViewController().present(alertView, animated: true, completion: nil)
    }
    
    func promptFor<Action>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> where Action : CustomStringConvertible {
        return Observable.create { observer in
            
            let alertView = UIAlertController(title: "Wiki search", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .default, handler: {
                _ in
                observer.on(.next(cancelAction))
            }))
            
            for action in actions{
                
                alertView.addAction(UIAlertAction(title: action.description, style: .default, handler: { (_) in
                    observer.on(.next(action))
                }))
            }
            
            DefaultWireFrame.rootViewController().present(alertView, animated: true, completion: nil)
            
            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
            
        }
    }
    
    
    static let shared = DefaultWireFrame()
    
    
}

extension RetyResult: CustomStringConvertible{
    var description: String{
        switch self{
        
        case .retry: return "Retry"
        case .cancel: return "Cancel"
        }
    }
}
