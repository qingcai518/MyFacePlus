//
//  FaceManager.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import AVFoundation

class FaceManager {
    static let shared = FaceManager()
    private init() {}
    
    func showAllFilters() {
        let filterNames = CIFilter.filterNames(inCategory: kCICategoryBuiltIn)
        let _ = filterNames.map{print($0)}
    }

    func makeMosaicFace(with inputImage: CIImage?, _ faceObject: AVMetadataFaceObject?) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let faceObject = faceObject else {return nil}
        guard let filter = CIFilter(name: "CIPixellate") else {return nil}
        
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(max(inputImage.extent.size.width, inputImage.extent.size.height) / 60, forKey: kCIInputScaleKey)
        
        let centerX = inputImage.extent.size.width * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2)
        let centerY = inputImage.extent.size.height * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2)
        let radius = faceObject.bounds.size.width * inputImage.extent.size.width / 2
        
        let params: [String: Any] = [
            "inputRadius0" : radius,
            "inputRadius1" : radius + 1,
            "inputColor0" : CIColor(red: 0, green: 1, blue: 0, alpha: 1),
            "inputColor1" : CIColor(red: 0, green: 0, blue: 0, alpha: 0),
            kCIInputCenterKey : CIVector(x: centerX, y: centerY)
        ]
        
        guard let radialGradient = CIFilter(name: "CIRadialGradient", withInputParameters: params) else {return nil}
        guard let radialGradientOutputImage = radialGradient.outputImage?.cropping(to: inputImage.extent) else {return nil}
        
        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {return nil}
        blendFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(radialGradientOutputImage, forKey: kCIInputMaskImageKey)
        
        return blendFilter.outputImage
    }
    
//    func makeBarcaFace(with inputImage: CIImage?, _ faceObject: AVMetadataFaceObject?) -> CIImage? {
//        guard let personciImage = inputImage else {return nil}
//        guard let faceObject = faceObject else {return nil}
//        
//        var persionPic = UIImage(ciImage: personciImage)
//        
//        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
//        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
//        let faces = faceDetector?.features(in: personciImage)
//        
//        // 转换坐标系
//        let ciImageSize = personciImage.extent.size
//        var transform = CGAffineTransform(scaleX: 1, y: -1)
//        transform = transform.translatedBy(x: 0, y: -ciImageSize.height)
//        
//        for face in faces as! [CIFaceFeature] {
//            print("Found bounds are \(face.bounds)")
//            // 应用变换转换坐标
//            var faceViewBounds = face.bounds.applying(transform)
//            // 在图像视图中计算矩形的实际位置和大小
//            
////            let viewSize = personPic.bounds.size
//            let viewSize = CGSize(width: 80, height: 80)
//            let scale = min(viewSize.width / ciImageSize.width, viewSize.height / ciImageSize.height)
//            let offsetX = (viewSize.width - ciImageSize.width * scale) / 2
//            let offsetY = (viewSize.height - ciImageSize.height * scale) / 2
//            
//            faceViewBounds = faceViewBounds.applying(CGAffineTransform(scaleX: scale, y: scale))
//            faceViewBounds.origin.x += offsetX
//            faceViewBounds.origin.y += offsetY
//            
////            let faceBox = UIView(frame: faceViewBounds)
////            faceBox.layer.borderWidth = 3
////            faceBox.layer.borderColor = UIColor.red.cgColor
////            faceBox.backgroundColor = UIColor.clear
////            personPic.addSubview(faceBox)
//            
//            if face.hasLeftEyePosition {
//                print("Left eye bounds are \(face.leftEyePosition)")
//            }
//            
//            if face.hasRightEyePosition {
//                print("Right eye bounds are \(face.rightEyePosition)")
//            }
//        }
//    }
}
