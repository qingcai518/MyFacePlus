//
//  UIImage.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/12.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit

extension UIImage {
    func getImage(from rect : CGRect) -> UIImage? {
        if let cgImage = self.cgImage, let subImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: subImage)
        }
        
        return nil
    }
    
    func strechImage() -> UIImage? {
        guard let cgImage = self.cgImage else {return self}
        guard let filter = CIFilter(name: "CIStretchCrop") else {return self}
        let inputImage = CIImage(cgImage: cgImage)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        if let outputImage = filter.outputImage {
            return UIImage(ciImage: outputImage)
        }
        
        return self
    }
    
    func drawImage(in rect: CGRect, _ inputImage : UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        inputImage.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func applyStrech(in rect : CGRect) -> UIImage? {
        if let subImage = self.getImage(from: rect), let strechZone = subImage.strechImage() {
            return self.drawImage(in: rect, strechZone)
        }
        
        return nil
    }
}
