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
        let faceRect = getFaceFrame(in: inputImage, faceObject)
        
        // モザイクフィルタ.
        guard let pixelFilter = CIFilter(name: "CIPixellate") else {return nil}
        pixelFilter.setValue(inputImage, forKey: kCIInputImageKey)
        pixelFilter.setValue(60, forKey: kCIInputScaleKey)
        
        // 範囲フィルタ.
        let radius = faceObject.bounds.size.width * inputImage.extent.size.width
        let centerX = faceRect.origin.x + faceRect.size.width / 2
        let centerY = inputImage.extent.height - faceRect.origin.y - faceRect.size.height / 2
        let inputCenter = CIVector(x: centerX, y: centerY)
        guard let gradientFilter = CIFilter(name: "CIRadialGradient") else {return nil}
        gradientFilter.setValue(radius, forKey: "inputRadius0")
        gradientFilter.setValue(radius + 1, forKey: "inputRadius1")
        gradientFilter.setValue(inputCenter, forKey: kCIInputCenterKey)
        guard let gradientOutputImage = gradientFilter.outputImage?.cropping(to: inputImage.extent) else {return nil}

        // 合成フィルタ.
        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {return nil}
        blendFilter.setValue(pixelFilter.outputImage, forKey: kCIInputImageKey)
        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
        blendFilter.setValue(gradientOutputImage, forKey: kCIInputMaskImageKey)
        return blendFilter.outputImage
    }
    
    func makeGlassFace(with inputImage : CIImage?, _ context: CIContext) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let maskUIImage = UIImage(named: "icon_face6") else {return inputImage}
        let maskImage = CIImage(image: maskUIImage)
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        guard let features = detector?.features(in: inputImage) else {return nil}
        
        for feature in features {
            guard let faceFeature = feature as? CIFaceFeature else {continue}
            let leftEyePosition = faceFeature.leftEyePosition
            
            print("left eye position = \(leftEyePosition)")
            
            // 合成.
            guard let blendFilter = CIFilter(name: "CIMultiplyBlendMode") else {return nil}
            blendFilter.setValue(inputImage, forKey: kCIInputImageKey)
            blendFilter.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
            
            return blendFilter.outputImage
        }
        
        print("1111")
        return inputImage
    }
    
    func makeShinFace(with inputImage : CIImage?, _ faceObject : AVMetadataFaceObject?, _ value: Float) -> CIImage? {
        guard let inputImage = inputImage else {return nil}
        guard let faceObject = faceObject else {return nil}
        
        // thin対象部分を取得する.
        
        let faceRect = getFaceFrame(in: inputImage, faceObject)
        let partRect = CGRect(x: faceRect.origin.x, y: faceRect.origin.y + faceRect.size.height * 2 / 3, width: faceRect.size.width, height: faceRect.size.height / 3)
        
//        guard let filter = CIFilter(name: "CIStretchCrop") else {return inputImage}
//        filter.setDefaults()
//        filter.setValue(inputImage, forKey: kCIInputImageKey)
//        filter.setValue(value, forKey: "inputCenterStretchAmount")
//        filter.setValue(0, forKey: "inputCropAmount")
        
//        // 範囲フィルタ.
//        let radius = faceObject.bounds.size.width * inputImage.extent.size.width / 3
//        let centerX = partRect.origin.x + partRect.size.width / 2
//        let centerY = inputImage.extent.height - partRect.maxY
//        let inputCenter = CIVector(x: centerX, y: centerY)
//        guard let gradientFilter = CIFilter(name: "CIRadialGradient") else {return nil}
//        gradientFilter.setValue(radius, forKey: "inputRadius0")
//        gradientFilter.setValue(radius + 1, forKey: "inputRadius1")
//        gradientFilter.setValue(inputCenter, forKey: kCIInputCenterKey)
//        guard let gradientOutputImage = gradientFilter.outputImage?.cropping(to: inputImage.extent) else {return nil}
//        // 合成フィルタ.
//        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {return nil}
//        blendFilter.setValue(filter.outputImage, forKey: kCIInputImageKey)
//        blendFilter.setValue(inputImage, forKey: kCIInputBackgroundImageKey)
//        blendFilter.setValue(gradientOutputImage, forKey: kCIInputMaskImageKey)
//        return blendFilter.outputImage
        
        // 画像を切る.
        let frameVector = CIVector(x: partRect.origin.x, y: inputImage.extent.size.height - partRect.origin.y - partRect.size.height, z: partRect.size.width, w: partRect.size.height)
        guard let cropFilter = CIFilter(name: "CICrop") else {
            return inputImage
        }
        cropFilter.setDefaults()
        cropFilter.setValue(inputImage, forKeyPath: kCIInputImageKey)
        cropFilter.setValue(frameVector, forKeyPath: "inputRectangle")
        
        // 切り取った画像を加工する.
        guard let filter = CIFilter(name: "CIStretchCrop") else {return inputImage}
        filter.setDefaults()
        filter.setValue(cropFilter.outputImage, forKeyPath: kCIInputImageKey)
        filter.setValue(value, forKeyPath: "inputCenterStretchAmount")
        filter.setValue(0, forKeyPath: "inputCropAmount")
        guard let outputImage = filter.outputImage?.cropping(to: partRect) else {return inputImage}
        
        // 加工後の画像と元の画像を併合する.
        guard let composeFilter = CIFilter(name: "CIMinimumCompositing") else {return inputImage}
        composeFilter.setValue(inputImage, forKeyPath: kCIInputImageKey)
        composeFilter.setValue(outputImage, forKeyPath: kCIInputBackgroundImageKey)
        
        return composeFilter.outputImage
    }
    
//    
//    func makeShinFace(with inputImage: CIImage?, _ faceObject : AVMetadataFaceObject?, _ value: Float ) -> CIImage? {
//        guard let inputImage = inputImage else {return nil}
//        guard let faceObject = faceObject else {return nil}
//        
//        // CIStretchCrop
//        guard let filter = CIFilter(name: "CIStretchCrop") else { return inputImage }
//        filter.setDefaults()
//        filter.setValue(inputImage, forKey: kCIInputImageKey)
//        filter.setValue(value, forKey: "inputCenterStretchAmount")
//        filter.setValue(0, forKey: "inputCropAmount")
//        // TODO. Thin face only a part of image.
//        
//        // 範囲フィルタ.
//        
//        
//        
//        return filter.outputImage
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
