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
    
//    func makeMosaicFace(with inputImage: CIImage?, _ faceObject: AVMetadataFaceObject?) -> CIImage? {
//        guard let inputImage = inputImage else {return nil}
//        guard let faceObject = faceObject else {return nil}
//        let faceRect = getFaceFrame(with: faceObject)
//        
//        guard let pixelFilter = CIFilter(name: "CIPixellate") else {return nil}
//        
//    }
    
    func makeMosaicFace(with inputImage: CIImage?, _ faceObject: AVMetadataFaceObject?) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let faceObject = faceObject else {return nil}
        let faceRect = getFaceFrame(in: inputImage, faceObject)
        
        // モザイクフィルタ.
        guard let pixelFilter = CIFilter(name: "CIPixellate") else {return nil}
        pixelFilter.setValue(inputImage, forKey: kCIInputImageKey)
        pixelFilter.setValue(60, forKey: kCIInputScaleKey)
        
//        // 範囲フィルタ.
//        let maxSize = max(faceRect.width * screenWidth / inputImage.extent.size.width, faceRect.height * screenHeight / inputImage.extent.size.height)
        let minSize = min(faceRect.width, faceRect.height)
        let centerX = faceRect.origin.x + faceRect.size.width / 2
        let centerY = inputImage.extent.height - faceRect.origin.y - faceRect.size.height / 2
        let inputCenter = CIVector(x: centerX, y: centerY)
        guard let gradientFilter = CIFilter(name: "CIRadialGradient") else {return nil}
        gradientFilter.setValue(minSize, forKey: "inputRadius0")
        gradientFilter.setValue(minSize + 1, forKey: "inputRadius1")
        gradientFilter.setValue(inputCenter, forKey: kCIInputCenterKey)
        guard let gradientOutputImage = gradientFilter.outputImage?.cropping(to: inputImage.extent) else {return nil}

        // 合成フィルタ.
        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {return nil}
        blendFilter.setValue(pixelFilter.outputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(gradientOutputImage, forKey: kCIInputMaskImageKey)
        return blendFilter.outputImage
    }
    
    func makeShinFace(with inputImage: CIImage?, _ faceObject : AVMetadataFaceObject?, _ value: Float ) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let faceObject = faceObject else {return nil}
        
        let faceRect = getFaceFrame(with: faceObject)
        // ここの部分をfilterする.
        let partRect = CGRect(x: faceRect.origin.x, y: faceRect.origin.y + faceRect.height * 2 / 3, width: faceRect.width, height: faceRect.height / 3)
        
        // CIStretchCrop
        guard let filter = CIFilter(name: "CIStretchCrop") else { return inputImage }
        filter.setDefaults()
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(value, forKey: "inputCenterStretchAmount")
        filter.setValue(0, forKey: "inputCropAmount")
        // TODO. Thin face only a part of image.
        
        // 選択範囲.
        guard let gradientFilter = CIFilter(name: "CIRadialGradient") else {return nil}
        gradientFilter.setValue(partRect.width, forKey: "inputRadius0")
        gradientFilter.setValue(partRect.width + 1, forKey: "inputRadius1")
        
        let centerX = partRect.origin.x + partRect.width / 2
        let centerY = partRect.origin.y + partRect.height / 2
        let inputCenter = CIVector(x: centerX, y: centerY)
        gradientFilter.setValue(inputCenter, forKey: kCIInputCenterKey)
        guard let gradientOutputImage = gradientFilter.outputImage?.cropping(to: inputImage.extent) else {return nil}

        // 合成
        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {return nil}
        blendFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(gradientOutputImage, forKey: kCIInputMaskImageKey)
        
        return blendFilter.outputImage
    }
    
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
    
    func getFaceFrame(in inputImage: CIImage, _ faceObject : AVMetadataFaceObject) -> CGRect {
        let centerX = inputImage.extent.width * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2)
        let centerY = inputImage.extent.height * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2)
        let width = inputImage.extent.width * faceObject.bounds.size.height
        let height = inputImage.extent.height * faceObject.bounds.size.width
        
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
