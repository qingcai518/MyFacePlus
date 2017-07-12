//
//  AppConstants.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

let orientation = UIDevice.current.orientation

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

enum CameraMode: Int {
    case normal = 0
    case faces
}

enum FaceType: Int {
    case normal = 0
    case mosaic
    case barca
    case butterfly
    case cat
    case picachu
    case glass
    case wolf
    case shit
    case dog
    case girl
}

struct UDKey {
}
