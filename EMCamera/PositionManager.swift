//
//  PositionManager.swift
//  EMCamera
//
//  Created by Митько Евгений on 26.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit
import AVFoundation

internal typealias ElementTupleSize = (width: CGFloat, height: CGFloat, fromSide: CGFloat)
internal let captureButton: ElementTupleSize = (width: 75, height: 75, fromSide: 0)
internal let cameraRollArrow: ElementTupleSize = (width: 40, height: 40, fromSide: 0)
internal let zoomLevelLabel: ElementTupleSize = (width: 25, height: 25, fromSide: 8)

class PositionManager {
        
    let screen = (width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    var lastImageOrientation = UIImageOrientation.right
    var lastVideoOrientation = AVCaptureVideoOrientation.portrait

    public func frames() -> (captureButton: CGRect, cameraRollArrow: CGRect, zoomLevelLabel: CGRect) {
        return (frameForCaptureButton(), frameForCameraRollArrow(), frameForZoomLabel())
    }
    
    private func frameForCaptureButton() -> CGRect {
        var captureButtonFrame = CGRect(x: (screen.width  - captureButton.width) / 2,
                                        y: screen.height - captureButton.height - captureButton.fromSide - cameraRollArrow.height - cameraRollArrow.fromSide,
                                        width: captureButton.width,
                                        height: captureButton.height)
        //Change origin dependend on screen orientation at startup
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            captureButtonFrame.origin = CGPoint(x: screen.width  - captureButton.width - captureButton.fromSide - cameraRollArrow.width - cameraRollArrow.fromSide, y: (screen.height  - captureButton.height) / 2)
        case .landscapeLeft:
            captureButtonFrame.origin = CGPoint(x: captureButton.fromSide + cameraRollArrow.height + cameraRollArrow.fromSide, y: (screen.height  - captureButton.height) / 2)
        case .portraitUpsideDown:
            captureButtonFrame.origin = CGPoint(x: (screen.width  - captureButton.width) / 2,
                                                y: cameraRollArrow.fromSide)
        default:
            break
        }
        return captureButtonFrame
    }

    private func frameForCameraRollArrow() -> CGRect {
        var arrowFrame = CGRect(x: (screen.width  - cameraRollArrow.width) / 2,
                                y: screen.height - cameraRollArrow.height - cameraRollArrow.fromSide,
                                width: cameraRollArrow.width,
                                height: cameraRollArrow.height)
        //Change origin dependend on screen orientation at startup
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            arrowFrame.origin = CGPoint(x: screen.width  - cameraRollArrow.width - cameraRollArrow.fromSide,
                                        y: (screen.height  - cameraRollArrow.height) / 2)
        case .landscapeLeft:
            arrowFrame.origin = CGPoint(x: cameraRollArrow.fromSide,
                                        y: (screen.height  - cameraRollArrow.height) / 2)
        case .portraitUpsideDown:
            arrowFrame.origin = CGPoint(x: (screen.width  - cameraRollArrow.height) / 2,
                                        y: cameraRollArrow.fromSide)
        default:
            break
        }
            return arrowFrame
    }
    
    private func frameForZoomLabel() -> CGRect {
        var zoomFrame = CGRect(x: (screen.width  - zoomLevelLabel.width) / 2,
                                y: zoomLevelLabel.fromSide,
                                width: zoomLevelLabel.width,
                                height: zoomLevelLabel.height)
        //Change origin dependend on screen orientation at startup
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            zoomFrame.origin = CGPoint(x: screen.width  - zoomLevelLabel.width - zoomLevelLabel.fromSide,
                                        y: (screen.height  - zoomLevelLabel.height))
        case .landscapeLeft:
            zoomFrame.origin = CGPoint(x: zoomLevelLabel.fromSide,
                                        y: (screen.height  - zoomLevelLabel.height) / 2)
        case .portraitUpsideDown:
            zoomFrame.origin = CGPoint(x: (screen.width  - zoomLevelLabel.height) / 2,
                                        y: screen.height - zoomLevelLabel.height - zoomLevelLabel.fromSide)
        default:
            break
        }
        return zoomFrame
    }

    public func orientation() -> (image: UIImageOrientation, video: AVCaptureVideoOrientation) {
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
    
    public func transformForOrientation() -> CGAffineTransform? {
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


