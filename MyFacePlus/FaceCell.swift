//
//  FaceCell.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

class FaceCell: UICollectionViewCell {
    @IBOutlet weak var imgView : UIImageView!
    
    func configure(with image: UIImage) {
        imgView.image = image
    }
}
