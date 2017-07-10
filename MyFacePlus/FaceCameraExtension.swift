//
//  FaceCameraExtension.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import AVFoundation
import UIKit

extension FaceCameraController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
            let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer) else {return}
        
        videoDimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
        sampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
        
        ciImage = CIImage(cvImageBuffer: imageBuffer)
        
        if let image = self.filter.outputImage {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = image
        }

        // モザイク
        if let image = FaceManager.shared.makeMosaicFace(with: ciImage, faceObject) {
            ciImage = image
        }
        
        // TODO. その他画像.
        
        var transform = CGAffineTransform(rotationAngle: 0)
        switch orientation {
        case .portrait:
            transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0))
        case .portraitUpsideDown:
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        case .landscapeRight:
            transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        default:
            transform = CGAffineTransform(rotationAngle: 0)
        }
        ciImage = ciImage?.applying(transform)
        DispatchQueue.main.async {
            if let image = self.ciImage {
                self.previewLayer.contents = self.context.createCGImage(image, from: image.extent)
            }
        }
    }
}

extension FaceCameraController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        faceObject = metadataObjects.count > 0 ? metadataObjects.first as? AVMetadataFaceObject : nil
    }
}

extension FaceCameraController: UICollectionViewDelegate {
}

extension FaceCameraController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = screenWidth / 6
        return CGSize(width: width, height: width)
    }
}

extension FaceCameraController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.faceImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let faceCell = cell as? FaceCell else {return}
        faceCell.configure(with: viewModel.faceImages[indexPath.item])
    }
}
