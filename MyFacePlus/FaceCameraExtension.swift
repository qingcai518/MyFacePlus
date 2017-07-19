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
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        ciImage = CIImage(cvImageBuffer: imageBuffer)
        if let image = self.filter.outputImage {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = image
        }
        
        // モザイクを選択する場合.
        if viewModel.faceType == .mosaic {
            if let image = FaceManager.shared.makeMosaicFace(with: ciImage, faceObject) {ciImage = image}
        } else if viewModel.faceType == .girl {
            if let image = FaceManager.shared.makeShinFace(with: ciImage, faceObject, 1 -
                slider.value) {ciImage = image}
        }
        
        // fit screen.
        switch orientation {
        case .landscapeRight:
            connection.videoOrientation = .landscapeRight
        case .landscapeLeft:
            connection.videoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            connection.videoOrientation = .portrait
        }
        
//        switch orientation {
//        case .portrait:
//            ciImage = ciImage?.applying(CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2.0)))
//        case .portraitUpsideDown:
//            ciImage = ciImage?.applying(CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0)))
//        case .landscapeRight:
//            ciImage = ciImage?.applying(CGAffineTransform(rotationAngle: CGFloat(Double.pi)))
//        default:
//            break
//        }

        DispatchQueue.main.async {
            if let image = self.ciImage {
                self.previewLayer.contents = self.context.createCGImage(image, from: image.extent)
            }
            // 他の効果を選択した場合
            self.addEffective(self.viewModel.faceType)
        }
    }
    
    /**
     * FaceTypeにより、効果を追加する.
     */
    private func addEffective(_ type: FaceType) {
        switch type {
        case .barca:
            addBarcaView()
            removeSlider()
            removeGlass()
        case .girl:
            addSlider()
            removeBarcaView()
            removeGlass()
        case .glass:
            addGlass()
            removeSlider()
            removeBarcaView()
        default:
            removeBarcaView()
            removeSlider()
            removeGlass()
        }
    }
}

/**
 * face1. barca
 */
extension FaceCameraController {
    fileprivate func addBarcaView() {
        guard let faceObject = faceObject else {
            removeBarcaView()
            return
        }
        
        let faceFrame = FaceManager.shared.getFaceFrame(with: faceObject)
        if barcaView == nil, let tempView = UINib(nibName: "BarcaView", bundle: nil).instantiate(withOwner: self, options: nil).first as? BarcaView {
            barcaView = tempView
            self.view.addSubview(barcaView)
            self.view.bringSubview(toFront: collectionView)
            self.view.bringSubview(toFront: showFaceBtn)
            self.view.bringSubview(toFront: cameraBtn)
            self.view.bringSubview(toFront: closeView)
            self.view.bringSubview(toFront: switchBtn)
        }
        
        barcaView.setIconPosition(faceFrame.origin.x, faceFrame.origin.y, faceFrame.width, faceFrame.height)
        
        let recognizer = UITapGestureRecognizer()
        recognizer.rx.event.bind { [weak self] sender in
            self?.viewModel.mode.value = .normal
        }.addDisposableTo(disposeBag)
        barcaView.addGestureRecognizer(recognizer)
    }
    
    fileprivate func removeBarcaView() {
        if barcaView != nil {
            barcaView.removeFromSuperview()
            barcaView = nil
        }
    }
}

/**
 * face7. glass.
 */
extension FaceCameraController {
    fileprivate func addGlass() {
        guard let ciImage = ciImage else {return}
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        guard let faceFeatures = detector?.features(in: ciImage) else {return}
        
        var faceFeatureCount = 0
        for feature in faceFeatures {
            guard let faceFeature = feature as? CIFaceFeature else {continue}

            let leftEyePosition = faceFeature.leftEyePosition
            let rightEyePosition = faceFeature.rightEyePosition
            
            faceFeatureCount += 1

            if leftEyeView == nil {
                leftEyeView = UIView()
                leftEyeView.backgroundColor = UIColor.green
                view.addSubview(leftEyeView)
            }
            leftEyeView.frame = CGRect(x: leftEyePosition.x * screenWidth / ciImage.extent.size.width, y: (ciImage.extent.size.height - leftEyePosition.y) * screenHeight / ciImage.extent.height, width: 100, height: 20)
            
            if rightEyeView == nil {
                rightEyeView = UIView()
                rightEyeView.backgroundColor = UIColor.red
                view.addSubview(rightEyeView)
            }
            rightEyeView.frame = CGRect(x: rightEyePosition.x * screenWidth / ciImage.extent.size.width, y: (ciImage.extent.size.height - rightEyePosition.y) * screenHeight / ciImage.extent.height, width: 100, height: 20)
            break
        }
        
        if faceFeatureCount == 0 {
            removeGlass()
        }
    }
    
    fileprivate func removeGlass() {
        if leftEyeView != nil {
            print("remove left")
            leftEyeView.removeFromSuperview()
            leftEyeView = nil
        }
        
        if rightEyeView != nil {
            print("remove right")
            rightEyeView.removeFromSuperview()
            rightEyeView = nil
        }
    }
}

/**
 * face10. modify face
 */
extension FaceCameraController {
    fileprivate func addSlider() {
        slider.isHidden = false
        
//        detectFace()
    }
    
    fileprivate func removeSlider() {
        slider.isHidden = true
        
        if (tempView != nil) {
            tempView.removeFromSuperview()
            tempView = nil
        }
    }
    
    private func detectFace() {
        guard let ciImage = ciImage else {return}
        
        let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyLow])
        guard let faceFeatures = detector?.features(in: ciImage) else {return}
        
        var faceFeatureCount = 0
        for feature in faceFeatures {
            guard let faceFeature = feature as? CIFaceFeature else {continue}
            
            faceFeatureCount += 1
            let frame = FaceManager.shared.getFaceFrame(with: faceFeature, ciImage.extent.size)
            if tempView == nil {
                tempView = UIView()
                tempView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                self.view.addSubview(tempView)
            }
            
            tempView.frame = frame
        }
        
        if faceFeatureCount == 0, tempView != nil {
            tempView.removeFromSuperview()
            tempView = nil
        }
    }
}

extension FaceCameraController : AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        faceObject = metadataObjects.count > 0 ? metadataObjects.first as? AVMetadataFaceObject : nil
    }
}

extension FaceCameraController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.faceType = FaceType(rawValue: indexPath.item)!
        let _ = (0..<viewModel.faceInfos.value.count).map{ [weak self] index in
            guard let `self` = self else {return}
            let info = self.viewModel.faceInfos.value[index]
            info.isSelected.value = index == indexPath.item
        }
    }
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
        return viewModel.faceInfos.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "FaceCell", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let info = viewModel.faceInfos.value[indexPath.item]
        guard let faceCell = cell as? FaceCell else {return}
        faceCell.configure(with: info)
    }
}
