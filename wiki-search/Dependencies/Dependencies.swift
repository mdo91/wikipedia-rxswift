//
//  Dependencies.swift
//  wiki-search
//
//  Created by Mdo on 26/07/2021.
//

import Foundation
import RxSwift


class Dependencies{
    
    static let sharedDependencies = Dependencies() // singleton
    
    let URLSession = Foundation.URLSession.shared
    
    let backgroundWokrSchedular:ImmediateSchedulerType
    let mainSchedular: SerialDispatchQueueScheduler
    let wireframe:Wireframe
    let reacabilityService:ReachabilityService
    
    
    private init(){
        
        wireframe = DefaultWireFrame()
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWokrSchedular = OperationQueueScheduler(operationQueue: operationQueue)
        mainSchedular = MainScheduler.instance
        reacabilityService = try! DefaultReachabilityService()
    }
}
