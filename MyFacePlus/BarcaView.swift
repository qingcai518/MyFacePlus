//
//  BarcaView.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/11.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import RxSwift

class BarcaView: UIView {
    @IBOutlet weak var iconView : UIImageView!
    
    let disposeBag = DisposeBag()
    lazy var rx_timer = Observable<Int>.interval(0.5, scheduler: MainScheduler.instance).shareReplay(1)
    var currentImage = UIImage(named: "icon_face2")!
    var nextImage = UIImage(named: "icon_face2_big")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        backgroundColor = UIColor.init(white: 0, alpha: 0)
        
        let defaultSize = CGFloat(44)
        setIconPosition((screenWidth - defaultSize) / 2, (screenHeight - defaultSize) / 2, defaultSize, defaultSize)
        iconView.image = currentImage
//        iconView.image = UIImage.animatedImage(with: [UIImage(named: "icon_face2")!, UIImage(named: "icon_face2_big")!], duration: 1)
        
        startAnimation()
    }
}

extension BarcaView {
    func setIconPosition(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
        iconView.frame = CGRect(x: x, y: y, width: w, height: h)
    }
    
    fileprivate func startAnimation() {
        rx_timer.bind { [weak self] count in
            guard let `self` = self else {return}
            self.iconView.image = self.nextImage
            self.nextImage = self.currentImage
            self.currentImage = self.iconView.image!
        }.addDisposableTo(disposeBag)
    }
}
