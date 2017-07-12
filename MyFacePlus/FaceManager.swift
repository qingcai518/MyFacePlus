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
    
    func makeShinFace(with inputImage: CIImage?, _ faceObject : AVMetadataFaceObject?, _ value: Float ) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let faceObject = faceObject else {return nil}
        
        let faceRect = getFaceFrame(with: faceObject)
        let partRect = CGRect(x: faceRect.origin.x, y: faceRect.origin.y + faceRect.height * 2 / 3, width: faceRect.width, height: faceRect.height / 3)
        
        guard let filter = CIFilter(name: "CIStretchCrop") else {
            print("failt to get filter.")
            return inputImage
        }
        
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: "inputCenterStretchAmount")
        filter.setValue(value, forKey: "inputCropAmount")
        
        return filter.outputImage
    }
    
//    private func strechImage(_ inputImage: CIImage, _ rect: CGRect) -> CIImage? {
//        guard let cgImage = CIContext(options: nil).createCGImage(inputImage, from: rect) else {
//            print("fail to get part cgImage")
//            return inputImage
//        }
//        
//        guard let filter = CIFilter(name: "CIStretchCrop") else {
//            print("fail to get filter.")
//            return inputImage
    
//        }
//        
//        filter.setDefaults()
//        let ciImage = CIImage(cgImage: cgImage)
//        filter.setValue(ciImage, forKey: kCIInputImageKey)
//        guard let partImage = filter.outputImage else {
//            print("333")
//            return inputImage
//        }
//        
//        // get base uiimage.
//        let baseImage = UIImage(ciImage: inputImage)
//        let maskImage = UIImage(ciImage: partImage)
//        
//        let result = mergeImage(baseImage, maskImage, rect)
//        return result?.ciImage
//    }
    
    
    /**
     * 图片合成
     */
    func mergeImage(_ baseImage: UIImage?, _ maskImage: UIImage?, _ maskFrame: CGRect) -> UIImage? {
        guard let base = baseImage else {return nil}
        guard let mask = maskImage else {return baseImage}

        UIGraphicsBeginImageContext(CGSize(width: screenWidth, height: screenHeight))
        base.draw(in: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        mask.draw(in: maskFrame)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func getFaceFrame(with faceObject : AVMetadataFaceObject) -> CGRect {
        let centerX = screenWidth * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2)
        let centerY = screenHeight * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2)
        
        let width = screenWidth * faceObject.bounds.size.height
        let height = screenHeight * faceObject.bounds.size.width
        
        let originX = centerX - width / 2
        let originY = centerY - height / 2
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    func getFaceFrame(with faceFeature: CIFaceFeature, _ imageSize: CGSize) -> CGRect {
        var originX = faceFeature.bounds.origin.x
        var originY = faceFeature.bounds.origin.y
        var width = faceFeature.bounds.width
        var height = faceFeature.bounds.height
        
        originX = originX * (screenWidth / imageSize.width)
        originY = originY * (screenHeight / imageSize.height)
        width = width * (screenWidth / imageSize.width)
        height = height * (screenHeight / imageSize.height)
        originY = screenHeight - height - originY    // 位置補正をする.
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
