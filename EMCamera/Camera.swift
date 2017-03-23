//
//  CameraViewController.swift
//  EMCamera
//
//  Created by Митько Евгений on 20.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import AVFoundation
import Photos

//Constatnts
fileprivate typealias ElementTupleSize = (width: CGFloat, height: CGFloat, bottom: CGFloat)
fileprivate let captureButton: ElementTupleSize = (width: 75, height: 75, bottom: 0)
fileprivate let cameraRollArrow: ElementTupleSize = (width: 40, height: 40, bottom: 0)

fileprivate let cameraRedColor = UIColor(red:0.90, green:0.23, blue:0.25, alpha:1.0)

protocol BurnCameraDelegate {
    func didTakePhoto(_ photo: UIImage)
    func didCaptureVideo(storedAt url: URL)
}

class Camera: UIViewController, AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate {
    
    var session = AVCaptureSession()
    
    
    var sessionImageOutput = AVCaptureStillImageOutput()
    var sessionVideoOutput = AVCaptureMovieFileOutput()
    
    var currentDevice: AVCaptureDevice?
    
    var delegate: BurnCameraDelegate?
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var cameraOrientation = AVCaptureVideoOrientation.portrait
    var captureButtonView = BlurredRoundedButton()
    var captureBorderView = UIView()
    var lastImageOrientation = UIImageOrientation.right
    var lastVideoOrientation = AVCaptureVideoOrientation.portrait
    var shutterEffectView = UIVisualEffectView()
    var shouldSaveImages = true
    var shouldSaveVideos = true
    var beginZoomScale: CGFloat = 1
    var zoomScale: CGFloat = 1
    var maxZoomScale: CGFloat = 1
    
    let fastAnimationTime: TimeInterval = 0.3
    let mediumAnimationTime: TimeInterval = 0.4
    let slowAnimationTime: TimeInterval = 0.5
    
    lazy var videoRecordingButtonEffect: UIView = {
        let view = UIView()
        view.center = self.captureButtonView.center
        view.frame = self.captureButtonView.frame
        view.backgroundColor = cameraRedColor
//        view.alpha = 0.6
        view.isUserInteractionEnabled = false
        view.layer.cornerRadius = captureButton.width
        view.layer.masksToBounds = true
        return view
    }()
    lazy var videoRecordingFrameEffect: UIView = {
        let view = UIView()
        view.frame = self.view.frame
        view.layer.borderColor = cameraRedColor.cgColor
        view.layer.borderWidth = 2
        view.isUserInteractionEnabled = false
        return view
    }()
    
    
    enum CameraMode {
        case image
        case video
    }
    
    class func show(on viewController: UIViewController) {
        Camera.show(on: viewController, shouldSaveImages: true, shouldSaveVideos: true)
    }
    
    class func show(on viewController: UIViewController, shouldSaveImages: Bool, shouldSaveVideos: Bool) {
        let camera = Camera()
        if let delegateVC = viewController as? BurnCameraDelegate {
            camera.delegate = delegateVC
        }
        camera.shouldSaveImages = shouldSaveImages
        camera.shouldSaveVideos = shouldSaveVideos
        viewController.present(camera, animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: - View Methods
    override func viewDidLoad() {
        setUpEverything()
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func didChangeOrientation() {
        print("didChangeOrientation")
    }
    
    
    //MARK: - Setup Methods
    private func setUpEverything() {
        setUpCameraView()
        setUpView()
    }
    
    private func setUpCameraView() {
        configure(.video)
        configure(.image)
        addPreviewLayer()
        addShutterLayer()
    }
    
    private func configure(_ mode: CameraMode) {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {return}
        for device in devices {
            if device.position == .back {
                currentDevice = device
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                    }
                    switch mode {
                    case .image:
                        configureImageOutput(for: device)
                    case .video:
                        configureVideoOutput(for: device)
                    }
                    session.startRunning()
                } catch (let error) {
                    print(error)
                }
            }
        }
        
    }
    
    private func addPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.frame
    }
    
    private func addZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.zoom(_:)))
        pinchGesture.delegate = self
        self.view.addGestureRecognizer(pinchGesture)
        setupMaxZoomScale()

    }
    
    fileprivate func setupMaxZoomScale() {
        if let currentDevice = currentDevice {
            maxZoomScale = currentDevice.activeFormat.videoMaxZoomFactor * 0.7
        }
    }

    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPinchGestureRecognizer {
            beginZoomScale = zoomScale
        }
        return true
    }
    
    @objc private func zoom(_ pinch: UIPinchGestureRecognizer) {
            zoom(scale: pinch.scale)
    }
    
    private func zoom(scale: CGFloat) {
        do {
            try currentDevice?.lockForConfiguration()
            zoomScale = max(1.0, min(beginZoomScale * scale, maxZoomScale))
            currentDevice?.videoZoomFactor = zoomScale
            currentDevice?.unlockForConfiguration()
        } catch {
            print("Error locking configuration")
        }
    }
    
    private func addShutterLayer() {
        shutterEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        shutterEffectView.frame = self.view.frame
        shutterEffectView.alpha = 0
        self.view.addSubview(shutterEffectView)
    }
    
    private func configureImageOutput(for device: AVCaptureDevice) {
        if session.canAddOutput(sessionImageOutput) {
            sessionImageOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            session.addOutput(sessionImageOutput)
        }
    }
    
    private func configureVideoOutput(for device: AVCaptureDevice) {
        if device.hasMediaType(AVMediaTypeVideo) && session.canAddOutput(sessionVideoOutput) {
            session.sessionPreset = AVCaptureSessionPresetHigh
            guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio) as? [AVCaptureDevice] else {return}
            for device in devices {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                        break
                    }
                } catch (let error) {
                    print(error)
                }
            }
            sessionVideoOutput.movieFragmentInterval = kCMTimeInvalid
            session.addOutput(sessionVideoOutput)
            session.commitConfiguration()
        }
    }
    
    private func setUpView() {
        setUpCaptureButton()
        setUpArrowIcon()
        addZoom()
    }
    
    private func setUpArrowIcon() {
        let arrow = StyleKit.imageOfArrowIcon2()
        let arrowButton = UIButton(type: .custom)
        arrowButton.frame = frames().cameraRollArrow
        if let transform = transformForOrientation() {
            arrowButton.transform = transform
        }
        arrowButton.setImage(arrow, for: .normal)
        arrowButton.contentMode = .center
        arrowButton.layer.shadowColor = UIColor.black.cgColor
        arrowButton.layer.shadowOffset = CGSize.zero
        arrowButton.layer.shadowRadius = 2
        arrowButton.layer.shadowOpacity = 0.5
        self.view.addSubview(arrowButton)
    }
    
    private func setUpCaptureButton() {
        //ConfigureView
        captureButtonView = BlurredRoundedButton(frame: frames().captureButton)
        captureButtonView.addTarget(self, action: #selector(self.takePhoto(_:)), for: .touchUpInside)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.takeVideo(_:)))
        longPress.minimumPressDuration = 0.4
        captureButtonView.addGestureRecognizer(longPress)
        self.view.addSubview(captureButtonView)
        captureBorderView = UIView(frame: CGRect(x: 0, y: 0, width: captureButton.width, height: captureButton.height))
        captureBorderView.layer.cornerRadius = captureButton.width / 2
        captureBorderView.layer.masksToBounds = true
        captureBorderView.layer.borderWidth = 5
        captureBorderView.layer.borderColor = UIColor.white.cgColor
        captureBorderView.alpha = 0.3
        captureBorderView.layer.shadowColor = UIColor.black.cgColor
        captureBorderView.layer.shadowOffset = CGSize.zero
        captureBorderView.layer.shadowRadius = 3
        captureBorderView.layer.shadowOpacity = 0.7
        captureButtonView.addSubview(captureBorderView)
    }
    
    //MARK: - Actions
    @objc private func takePhoto(_ button: UIButton) {
        print("gonna take photo")
        configure(.image)
        if let imageConnection = sessionImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            captureButtonView.isEnabled = false
            
            self.animateShutterView()
            sessionImageOutput.captureStillImageAsynchronously(from: imageConnection, completionHandler: { (sampleBuffer, error) in
                self.captureButtonView.isEnabled = true
                if let sampleBuffer = sampleBuffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer), let dataProvider = CGDataProvider(data: imageData as CFData), let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                    let image = UIImage(cgImage: cgImageRef, scale: 1, orientation: self.orientation().image)
                    if self.shouldSaveImages {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    self.delegate?.didTakePhoto(image)
                }
            })
        }
    }
    
    @objc private func takeVideo(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            videoRecordingButtonEffect.layer.removeAllAnimations()
            print("begin take video")
            configure(.video)
            if let videoConnection = sessionVideoOutput.connection(withMediaType: AVMediaTypeVideo) {
                if videoConnection.isVideoOrientationSupported {
                    videoConnection.videoOrientation = orientation().video
                }
                let fileName = "yourAwesomeVideo.mp4";
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let filePath = documentsURL.appendingPathComponent(fileName)
                sessionVideoOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
                setCaptureButtonToVideoMode(on: true)
            }
        case .ended, .cancelled:
            print("end take video")
            sessionVideoOutput.stopRecording()
            setCaptureButtonToVideoMode(on: false)
        default:
            break
        }
    }
    
    
    //MARK: - UI Elements Customization Helpers
    var animateVideoButton = false
    private func setCaptureButtonToVideoMode(on isOn: Bool) {
        if isOn {
            self.view.insertSubview(videoRecordingButtonEffect, belowSubview: captureButtonView)
            self.view.addSubview(videoRecordingFrameEffect)
            animateShowingOfRecordEffect()
        } else {
            animateHidingOfRecordEffect()
        }
    }
    
    
    //MARK: - Animations methods
    private func animateShutterView() {
        let opacity = opacityAnimation(duration: self.fastAnimationTime / 2, autoreverses: true)
        self.shutterEffectView.layer.add(opacity, forKey: nil)
    }
    
    private func animateShowingOfRecordEffect() {
        self.videoRecordingButtonEffect.layer.opacity = 0.6
        self.videoRecordingFrameEffect.layer.opacity = 0.6
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            let repetedOpacity = self.opacityAnimation(duration: self.slowAnimationTime, from: 0.6, to: 1, repeatForever: true, autoreverses: true)
            let repetedScale = self.scaleAnimation(duration: self.slowAnimationTime, from: 1, to: 1.15, repeatForever: true, autoreverses: true)
            let group = self.animationGroup(from: [repetedOpacity, repetedScale])
            self.videoRecordingButtonEffect.layer.add(group, forKey: "scaleAndOpacity")
            self.videoRecordingFrameEffect.layer.add(repetedOpacity, forKey: "frameRepeatedOpacity")
        }
        let opacity = opacityAnimation(duration: self.fastAnimationTime, from: 0, to: 0.6)
        let scale = scaleAnimation(duration: self.fastAnimationTime, from: 0, to: 1)
        self.videoRecordingFrameEffect.layer.add(opacity, forKey: nil)
        self.videoRecordingButtonEffect.layer.add(scale, forKey: nil)
        CATransaction.commit()
    }
    
    private func animateHidingOfRecordEffect() {
        let currentOpacity = self.videoRecordingButtonEffect.layer.opacity
        self.videoRecordingButtonEffect.layer.removeAnimation(forKey: "scaleAndOpacity")
        self.videoRecordingFrameEffect.layer.removeAnimation(forKey: "frameRepeatedOpacity")
        self.videoRecordingButtonEffect.layer.opacity = 0
        self.videoRecordingFrameEffect.layer.opacity = 0
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.videoRecordingButtonEffect.removeFromSuperview()
            self.videoRecordingFrameEffect.removeFromSuperview()
        }
        let opacity = opacityAnimation(duration: self.mediumAnimationTime, from: currentOpacity, to: 0)
        self.videoRecordingFrameEffect.layer.add(opacity, forKey: nil)
        self.videoRecordingButtonEffect.layer.add(opacity, forKey: nil)
        CATransaction.commit()
    }
    
    private func opacityAnimation(duration: TimeInterval = 0.4, from: Float = 0, to: Float = 1, repeatForever: Bool = false, autoreverses: Bool = false) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        opacityAnimation.fromValue = from
        opacityAnimation.toValue = to
        opacityAnimation.repeatCount = repeatForever ? Float.greatestFiniteMagnitude : 0
        opacityAnimation.autoreverses = autoreverses
        return opacityAnimation
    }
    
    private func scaleAnimation(duration: TimeInterval = 0.4, from: CGFloat = 0, to: CGFloat = 1, repeatForever: Bool = false, autoreverses: Bool = false) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = CATransform3DMakeScale(from, from, 1)
        scaleAnimation.toValue = CATransform3DMakeScale(to, to, 1)
        scaleAnimation.repeatCount = repeatForever ? Float.greatestFiniteMagnitude : 0
        scaleAnimation.autoreverses = autoreverses
        return scaleAnimation
    }
    
    private func animationGroup(from animations: [CABasicAnimation]) -> CAAnimation {
        var duration = self.mediumAnimationTime
        var repeatCount: Float = 0
        var autoreverses = false
        if let firstAnimation = animations.first {
            duration = firstAnimation.duration
            repeatCount = firstAnimation.repeatCount
            autoreverses = firstAnimation.autoreverses
        }
        let group = CAAnimationGroup()
        group.animations = animations
        group.duration = duration
        group.repeatCount = repeatCount
        group.autoreverses = autoreverses
        return group
    }
    
    
    //MARK: - Helper methods
    private func orientation() -> (image: UIImageOrientation, video: AVCaptureVideoOrientation) {
        switch UIDevice.current.orientation {
        case .portrait:
            lastImageOrientation = .right
            lastVideoOrientation = .portrait
        case .landscapeLeft:
            lastImageOrientation = .up
            lastVideoOrientation = .landscapeRight
        case .landscapeRight:
            lastImageOrientation = .down
            lastVideoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            lastImageOrientation = .left
            lastVideoOrientation = .portraitUpsideDown
        default:
            break
        }
        return (lastImageOrientation, lastVideoOrientation)
    }
    
    private func frames() -> (captureButton: CGRect, cameraRollArrow: CGRect) {
        let screen = (width: self.view.frame.width, height: self.view.frame.height)
        //Frames for UI Elements
        var captureButtonFrame = CGRect(x: (screen.width  - captureButton.width) / 2,
                                        y: screen.height - captureButton.height - captureButton.bottom - cameraRollArrow.height - cameraRollArrow.bottom,
                                        width: captureButton.width,
                                        height: captureButton.height)
        var arrowFrame = CGRect(x: (screen.width  - cameraRollArrow.width) / 2,
                                y: screen.height - cameraRollArrow.height - cameraRollArrow.bottom,
                                width: cameraRollArrow.width,
                                height: cameraRollArrow.height)
        //Change origin dependend on screen orientation at startup
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            captureButtonFrame.origin = CGPoint(x: screen.width  - captureButton.width - captureButton.bottom - cameraRollArrow.width - cameraRollArrow.bottom, y: (screen.height  - captureButton.height) / 2)
            arrowFrame.origin = CGPoint(x: screen.width  - cameraRollArrow.width - cameraRollArrow.bottom,
                                        y: (screen.height  - cameraRollArrow.height) / 2)
        case .landscapeLeft:
            captureButtonFrame.origin = CGPoint(x: captureButton.bottom + cameraRollArrow.height + cameraRollArrow.bottom, y: (screen.height  - captureButton.height) / 2)
            arrowFrame.origin = CGPoint(x: cameraRollArrow.bottom,
                                        y: (screen.height  - cameraRollArrow.height) / 2)
        case .portraitUpsideDown:
            captureButtonFrame.origin = CGPoint(x: (screen.width  - captureButton.width) / 2,
                                                y: cameraRollArrow.bottom)
            arrowFrame.origin = CGPoint(x: (screen.width  - cameraRollArrow.height) / 2,
                                        y: cameraRollArrow.bottom)
        default:
            break
        }
        return (captureButtonFrame, arrowFrame)
    }
    
    
    private func transformForOrientation() -> CGAffineTransform? {
        var angle: CGFloat? = nil
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            angle = 0
        case .landscapeLeft:
            angle = .pi / 2
        case .landscapeRight:
            angle = .pi / -2
        case .portraitUpsideDown:
            angle = .pi
        default:
            break
        }
        if let angle = angle {
            return CGAffineTransform(rotationAngle: angle)
        } else {
            return nil
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("capture did finish")
        print(captureOutput)
        print(outputFileURL)
        if shouldSaveVideos {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { saved, error in
            }
        }
        delegate?.didCaptureVideo(storedAt: outputFileURL)
    }
    
    
    
}



