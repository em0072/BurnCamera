//
//  ViewController.swift
//  EMCamera
//
//  Created by Митько Евгений on 09.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit
import AVFoundation

//Constatnts
typealias ElementTupleSize = (width: CGFloat, height: CGFloat, bottom: CGFloat)
let captureButton: ElementTupleSize = (width: 80, height: 80, bottom: 0)
let cameraRollArrow: ElementTupleSize = (width: 40, height: 40, bottom: 0)

class ViewController: UIViewController {    
    
    var session = AVCaptureSession()
    var sessionOutput = AVCaptureStillImageOutput()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var cameraOrientation = AVCaptureVideoOrientation.portrait
    var captureButtonView: BlurredRoundedButton?
    var lastOrientation: UIImageOrientation?
    var shutterEffectView = UIVisualEffectView()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpEverything()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangeOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func didChangeOrientation() {
        print("didChangeOrientation")
    }

    private func setUpEverything() {
        setUpCameraView()
        setUpView()
    }
    
    private func setUpCameraView() {
        guard let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {return}
        session.sessionPreset = AVCaptureSessionPresetPhoto
        for device in devices {
            if device.position == .back {
                do {
                    let input = try AVCaptureDeviceInput(device: device)
                    if session.canAddInput(input) {
                        session.addInput(input)
                        sessionOutput.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                        if session.canAddOutput(sessionOutput) {
                            session.addOutput(sessionOutput)
                            session.startRunning()
                            previewLayer = AVCaptureVideoPreviewLayer(session: session)
                            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                            previewLayer.connection.videoOrientation = AVCaptureVideoOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue) ?? .portrait
                            self.view.layer.addSublayer(previewLayer)
                            previewLayer.frame = self.view.frame
                            shutterEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
                            shutterEffectView.frame = self.view.frame
                            shutterEffectView.alpha = 0
                            self.view.addSubview(shutterEffectView)
                        }
                    }
                } catch (let error) {
                    print(error)
                }
            }
        }
    }
    
    private func setUpView() {
        setUpCaptureButton()
        setUpArrowIcon()
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
        if captureButtonView == nil {
            captureButtonView = BlurredRoundedButton(frame: frames().captureButton)
            captureButtonView!.addTarget(self, action: #selector(self.takePhoto(_:)), for: .touchUpInside)
            self.view.addSubview(captureButtonView!)
            let borderView = UIView(frame: CGRect(x: 0, y: 0, width: captureButton.width, height: captureButton.height))
            borderView.layer.cornerRadius = captureButton.width / 2
            borderView.layer.masksToBounds = true
            borderView.layer.borderWidth = 5
            borderView.layer.borderColor = UIColor.white.cgColor
            borderView.alpha = 0.3
            borderView.layer.shadowColor = UIColor.black.cgColor
            borderView.layer.shadowOffset = CGSize.zero
            borderView.layer.shadowRadius = 3
            borderView.layer.shadowOpacity = 0.7
            captureButtonView!.addSubview(borderView)
        }
    }
    
    @objc private func takePhoto(_ button: UIButton) {
        print("gonna take photo")
        if let videoConnection = sessionOutput.connection(withMediaType: AVMediaTypeVideo) {
            captureButtonView?.isEnabled = false
            self.animateShutterView()
            sessionOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) in
                self.captureButtonView?.isEnabled = true
                if let sampleBuffer = sampleBuffer, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer), let dataProvider = CGDataProvider(data: imageData as CFData), let cgImageRef = CGImage(jpegDataProviderSource: dataProvider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) {
                    let image = UIImage(cgImage: cgImageRef, scale: 1, orientation: self.orientationForPhoto())
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            })
        }
    }
    
    private func animateShutterView() {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { 
                self.shutterEffectView.alpha = 1
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
                self.shutterEffectView.alpha = 0
            })
        }, completion: nil)
    }
    
    
    //MARK: - UI Elements Customisation
    private func orientationForPhoto() -> UIImageOrientation {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            lastOrientation = .right
            return lastOrientation!
        case .landscapeLeft:
            lastOrientation = .up
            return lastOrientation!
        case .landscapeRight:
            lastOrientation = .down
            return lastOrientation!
        case .portraitUpsideDown:
            lastOrientation = .left
            return lastOrientation!
        default:
            return lastOrientation ?? .right
        }
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
    
    
    func transformForOrientation() -> CGAffineTransform? {
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

}






