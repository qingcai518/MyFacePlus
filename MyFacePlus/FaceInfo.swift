//
//  FaceInfo.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import RxSwift

struct FaceInfo {
    var image: UIImage
    var isSelected = Variable(false)
    
    init(_ image: UIImage, _ isSelected: Bool) {
        self.image = image
        self.isSelected.value = isSelected
    }
}
