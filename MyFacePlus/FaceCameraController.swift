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

class FaceCameraController: AppViewController {
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var showFaceBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var closeView: UIView!
    
    // for mengpai.
    var barcaView : BarcaView!
    
    lazy var captureSession = AVCaptureSession()
    lazy var previewLayer = CALayer()
    lazy var filter = CIFilter()
    
    var faceObject : AVMetadataFaceObject?
    var deviceInput : AVCaptureDeviceInput?
    var captureDevice : AVCaptureDevice?
    var ciImage: CIImage?

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
        bind()
        setupPreviewLayer()
        setupCaptureSession()
        viewModel.getFaceInfos()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer.bounds.size = size
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
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
        let recognizer = UITapGestureRecognizer()
        recognizer.rx.event.bind { [weak self] sender in
            self?.viewModel.mode.value = .normal
        }.addDisposableTo(disposeBag)
        closeView.addGestureRecognizer(recognizer)
    }
    
    fileprivate func bind() {
        viewModel.mode.asObservable().bind { [weak self] mode in
            switch mode {
            case .normal:
                self?.toNormalMode()
            case .faces:
                self?.toFacesMode()
            }
        }.addDisposableTo(disposeBag)
        
        viewModel.faceInfos.asObservable().bind { [weak self] _ in
            self?.collectionView.reloadData()
        }.addDisposableTo(disposeBag)
    }
    
    private func toNormalMode() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let `self` = self else {return}
            if !self.collectionView.transform.isIdentity {return}
            self.collectionView.transform = CGAffineTransform(translationX: 0, y: self.collectionView.bounds.height)
            self.showFaceBtn.isHidden = false
            self.cameraBtn.transform = CGAffineTransform.identity
        }
    }
    
    private func toFacesMode() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.collectionView.transform = CGAffineTransform.identity
            self?.showFaceBtn.isHidden = true

            var transform = CATransform3DIdentity
            transform = CATransform3DScale(transform, 0.6, 0.6, 1.0)
            transform = CATransform3DTranslate(transform, 0, 100, 0)
           self?.cameraBtn.layer.transform = transform
        }
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
        viewModel.mode.value = .faces
    }
    
    @IBAction func takePicture() {
        guard let image = ciImage else {return}
        guard let cgImage = CIContext(options: nil).createCGImage(image, from: image.extent) else {return}
        var uiImage: UIImage? = UIImage(cgImage: cgImage)
        
        // 合成.
        switch viewModel.faceType {
        case .barca:
            let barcaIcon = barcaView.iconView.image
            let barcaFrame = barcaView.iconView.frame
            uiImage = FaceManager.shared.mergeImage(uiImage, barcaIcon, barcaFrame)
        default:
            break
        }

        guard let next = UIStoryboard(name: "Confirm", bundle: nil).instantiateInitialViewController() as? UINavigationController else {return}
        guard let confirmController = next.viewControllers.first as? ConfirmController else {return}
        confirmController.photo = uiImage
        self.present(next, animated: true, completion: nil)
    }
}
