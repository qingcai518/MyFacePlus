//
//  FaceCell.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import RxSwift

class FaceCell: UICollectionViewCell {
    @IBOutlet weak var imgView : UIImageView!
    lazy var circleView = UIView()
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func configure(with info: FaceInfo) {
        imgView.image = info.image
        info.isSelected.asObservable().bind { [weak self] value in
            if value {
                self?.addCircleView()
            } else {
                self?.removeCircleView()
            }
        }.addDisposableTo(disposeBag)
    }
    
    private func addCircleView() {
        let padding = CGFloat(6)
        let size = screenWidth / 6 - 2 * padding
        circleView.frame = CGRect(x: padding, y: padding, width: size, height: size)
        circleView.backgroundColor = UIColor.clear
        circleView.layer.cornerRadius = size / 2
        circleView.layer.borderWidth = 3
        circleView.layer.borderColor = UIColor.red.cgColor
        circleView.clipsToBounds = true
        contentView.addSubview(circleView)
    }
    
    private func removeCircleView() {
        circleView.removeFromSuperview()
    }
}
