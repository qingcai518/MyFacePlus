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
    
    func makeBarcaFace(with inputImage : CIImage?, _ faceObject : AVMetadataFaceObject?) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
//        guard let faceObject = faceObject else {return nil}
        
        let originImage = UIImage(ciImage: inputImage)
//        let barcaImage = UIImage.animatedImage(with: [UIImage(named: "icon_face2")!, UIImage(named: "icon_face2_big")!], duration: 0.3)
        let barcaImage = UIImage(named: "icon_face2")!
        
        let size = originImage.size
        UIGraphicsBeginImageContext(size)
        
        originImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        barcaImage.draw(in: CGRect(x: 30, y: 30, width: size.width - 60, height: size.height - 60))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = UIImagePNGRepresentation(result!)
        let ciImage = CIImage(data: data!)
        
        print("ciImage = \(ciImage)")
        
        return ciImage
    }
}
