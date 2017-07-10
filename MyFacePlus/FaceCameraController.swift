//
//  ViewController.swift
//  MyFacePlus
//
//  Created by liqc on 2017/07/10.
//  Copyright © 2017年 RN-079. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class FaceCameraController: UIViewController {
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var showFaceBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    
    lazy var captureSession = AVCaptureSession()
    lazy var previewLayer = CALayer()
    lazy var filter = CIFilter()
    
    var ciImage: CIImage?
    var faceObject : AVMetadataFaceObject?
    var sampleTime: CMTime?
    var videoDimensions: CMVideoDimensions?
    var deviceInput : AVCaptureDeviceInput?
    var captureDevice : AVCaptureDevice?

    lazy var context: CIContext = {
        let eaglContext = EAGLContext(api: EAGLRenderingAPI.openGLES2)
        let options = [kCIContextWorkingColorSpace : NSNull()]
        return CIContext(eaglContext: eaglContext!, options: options)
    }()
    
    let viewModel = FaceCameraViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        setView()
        setupPreviewLayer()
        setupCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer.bounds.size = size
    }
}

extension FaceCameraController {
    fileprivate func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        collectionView.transform = CGAffineTransform(translationX: 0, y: collectionView.bounds.height)
    }
    
    fileprivate func setView() {
        let recgonizer = UITapGestureRecognizer()
    }
    
    fileprivate func setupPreviewLayer() {
        previewLayer.anchorPoint = CGPoint.zero
        previewLayer.bounds = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    fileprivate func setupCaptureSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        captureDevice = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).first as? AVCaptureDevice
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(deviceInput)
        } catch {
            return print("fail to setup capture session")
        }

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : Int(kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoqueue"))
        captureSession.addOutput(dataOutput)
        
        // face dect.
        let metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
        
        captureSession.commitConfiguration()
        
        captureSession.startRunning()
    }
}

extension FaceCameraController {
    @IBAction func doSwitch() {
        guard let position = captureDevice?.position else {return}
        captureSession.removeInput(deviceInput)
        switch position {
        case .back:
            captureDevice = getDevice(with: .front)
        case .front:
            captureDevice = getDevice(with: .back)
        default:
            break
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(deviceInput)
        } catch {
            return print("fail to setup capture session")
        }
        
        let animation = CATransition.init()
        animation.duration = 0.25
        animation.subtype = kCATruncationMiddle
        animation.type = kCATransitionFade
        self.view.layer.add(animation, forKey: nil)
        faceObject = nil
    }
    
    private func getDevice(with position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) else {return nil}
        return devices.map{$0 as? AVCaptureDevice}.filter{$0?.position == position}.first as? AVCaptureDevice
    }
    
    @IBAction func showFaces() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionView.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func takePicture() {
        
    }
}
