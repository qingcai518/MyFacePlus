//
//  FaceCameraViewModel.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import RxSwift

class FaceCameraViewModel {
    var mode = Variable(CameraMode.normal)
    var faceType = FaceType.normal
    var faceInfos = Variable([FaceInfo]())
    
    func getFaceInfos() {
        var result = [FaceInfo]()
        result.append(FaceInfo(UIImage(named: "icon_face0")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face1")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face2")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face3")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face4")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face5")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face6")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face7")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face8")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face9")!, false))
        result.append(FaceInfo(UIImage(named: "icon_face10")!, false))
        
        let _ = (0..<result.count).filter{faceType.rawValue == $0}.map{result[$0].isSelected.value = true}
        faceInfos.value = result
    }
}
