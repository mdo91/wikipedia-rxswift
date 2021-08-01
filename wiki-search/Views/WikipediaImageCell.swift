//
//  WikipediaImageCell.swift
//  wiki-search
//
//  Created by Mdo on 23/07/2021.
//

import UIKit

import RxCocoa
import RxSwift

enum DownloadableImage{
    
    case content(image:Image)
    case offlinePlaceholder
}

typealias Image = UIImage

class WikipediaImageCell: UICollectionViewCell {
    
    //MARK:- properties & outlets
    
    @IBOutlet var imageOutlet:UIImageView!
    
    var disposeBag:DisposeBag?
    
    var downloadableImage:Observable<DownloadableImage>?{
        
        didSet{
            
         //   print("downloadableImage \(downloadableImage.debugDescription)")
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .debug()
                
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageOutlet.rx.downloadableImage)
                .disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
                
                
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        downloadableImage = nil
        disposeBag = nil
    }
    
    deinit {
        
    }

}
