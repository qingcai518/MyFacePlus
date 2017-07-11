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
        
        var ciImage = CIImage(cvImageBuffer: imageBuffer)
        if let image = self.filter.outputImage {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = image
        }
        
        // モザイクを選択する場合.
        if viewModel.faceType == .mosaic {
            if let image = FaceManager.shared.makeMosaicFace(with: ciImage, faceObject) {ciImage = image}
        }
        
        // fit screen.
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
        ciImage = ciImage.applying(transform)

        
        DispatchQueue.main.async {
            self.previewLayer.contents = self.context.createCGImage(ciImage, from: ciImage.extent)
            // 他の効果を選択した場合
            self.addEffective(self.viewModel.faceType, ciImage)
        }
    }
    
    /**
     * FaceTypeにより、効果を追加する.
     */
    private func addEffective(_ type: FaceType, _ ciImage: CIImage?) {
        switch type {
        case .barca:
            addBarcaView(ciImage)
        default:
            removeBarcaView()
        }
    }
    
    /**
     * 種類2の効果 : BarcaView.
     */
    private func addBarcaView(_ ciImage : CIImage?) {
        guard let inputImage = ciImage else {return}
        
        // 顔を検知されなかった場合.
        guard let faceObject = faceObject else {
            removeBarcaView()
            return
        }
        
        //-90度算法
        let originX = view.bounds.size.width * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2)
        let originY = view.bounds.size.height * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2)
        
        let width = view.bounds.size.width * faceObject.bounds.size.height
        let height = view.bounds.size.height * faceObject.bounds.size.width
        
//        let position = CGPoint(x: view.bounds.width * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2), y: view.bounds.height * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2))
//        
//        let size = CGSize(width: faceObject.bounds.size.height * view.bounds.width, height: faceObject.bounds.size.width * view.bounds.height)
        
        print("originX = \(originX), originY = \(originY), width = \(width), height = \(height)")
        
        // 其他算法
//        let centerX = view.bounds.size.width * (faceObject.bounds.origin.x + faceObject.bounds.size.width / 2)
//        let centerY = view.bounds.size.height * (1 - faceObject.bounds.origin.y - faceObject.bounds.size.height / 2)
//        let radius = faceObject.bounds.size.width * view.bounds.size.width / 2
//        
//        print("centerX = \(centerX), centerY = \(centerY), radius = \(radius)")
        
        
        // 顔を検知された場合.
        if barcaView == nil, let tempView = UINib(nibName: "BarcaView", bundle: nil).instantiate(withOwner: self, options: nil).first as? BarcaView {
            barcaView = tempView
            self.view.addSubview(barcaView)
        }
        barcaView.setIconPosition(originX, originY, width, height)
    }
    
    private func removeBarcaView() {
        if barcaView != nil {
            barcaView.removeFromSuperview()
            barcaView = nil
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
