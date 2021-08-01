//
//  ImageService.swift
//  wiki-search
//
//  Created by Mdo on 26/07/2021.
//

import Foundation
import RxCocoa
import UIKit
import RxSwift

protocol ImageService {
    func imageFromURL(_ url:URL, reachabilityService:ReachabilityService) -> Observable<DownloadableImage>
}


class DefaultImageService:ImageService{

    
    
    static let sharedImageService = DefaultImageService() // singleton
    
    let `$`:Dependencies = Dependencies.sharedDependencies
    
    //1st level cache
    private let _imageCache = NSCache<AnyObject,AnyObject>()
    
    //2nd level cache
    
    private let _imageDataCache = NSCache<AnyObject,AnyObject>()
    
    let loadingImage = ActivityIndicator()
    
    private init(){
        
        _imageDataCache.totalCostLimit = 20 * MB
        _imageCache.countLimit = 20
    }
    
    private func decodeImage(_ imageData:Data) -> Observable<Image>{
        print("decodeImage.Data \(imageData)")
        return Observable.just(imageData)
            .observeOn(`$`.backgroundWokrSchedular)
            .map{ data in
                
                guard let image = Image(data: data) else{
                    throw apiError("Error during parsing")
                }
                return image.forceLazyDecomperssion()
                
            }
    }
    
    func _imageFromURL(_ url:URL) -> Observable<Image>{
        return Observable.deferred {
            
            let maybeImage = self._imageCache.object(forKey: url as AnyObject) as? Image
            
            var decodedImage: Observable<Image>
            
            if let image = maybeImage{
                decodedImage = Observable.just(image)
            }else{
                let cachedData = self._imageDataCache.object(forKey: url as AnyObject) as? Data
                // does image data cache contain any thing
                
                if let cachedData = cachedData{
                    decodedImage = self.decodeImage(cachedData)
                }else{
                    // fetch from network
               decodedImage = URLSession.shared.rx.data(request: URLRequest(url: url))
                        .observeOn(MainScheduler.instance)
                        .catchError({ (error) -> Observable<Data> in
                            print("catchError \(error.localizedDescription)")
                            return Observable.empty()
                        })
                        .do(onNext: {
                            data in
                            print("data result: \(data)")
                        },
                        onCompleted: {
                            print("onCompleted")
                        })
                        .flatMap(self.decodeImage)
                        .trackActivity(self.loadingImage)
                    
                //z    print("decodeImage \(String(describing: decodeImage))")
                    
                }

                
            }
            return decodedImage.do(onNext: { image in
                print("decodedImage rx")
                self._imageCache.setObject(image, forKey: url as AnyObject)
            })
            
        }
    }
    

    
    
    func imageFromURL(_ url: URL, reachabilityService: ReachabilityService) -> Observable<DownloadableImage> {
        
        return _imageFromURL(url)
            .map({DownloadableImage.content(image: $0)})
            .retryOnBecomesReachable(DownloadableImage.offlinePlaceholder, reachabilityService: reachabilityService)
            .startWith(.content(image: Image()))
        
    }
    
    
}

extension Reactive where Base: URLSession{
    
      func responseRequest(request:URLRequest) -> Observable<(HTTPURLResponse, Data)>{
        return Observable.create { observer  in
            
            // content goes here
            
            let task = self.base.dataTask(with: request){ data, response, error in
                
                guard let response = response,
                      let data = data else{
                    observer.onError(error ?? RxCocoaURLError.unknown)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else{
                    observer.onError(RxCocoaURLError.nonHTTPResponse(response: response))
                    return
                }
                observer.onNext((httpResponse,data))
                observer.onCompleted()
                
            }
            task.resume()
            return Disposables.create {
                task.cancel()
                
            }
        }
    }
     
    func data1(request:URLRequest) -> Observable<Data>{

        return responseRequest(request: request).map { response, data -> Data in
            guard 200 ..< 300 ~= response.statusCode else{
                throw RxCocoaURLError.httpRequestFailed(response: response, data: data)
            }
            print("response status code: \(response.statusCode)")
            return data
        }
    }
    
    func string(request:URLRequest) -> Observable<String>{
        
        return data(request: request).map { (data) in
            return String(data:data,encoding: .utf8) ?? ""
        }
    }
}

