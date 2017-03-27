//
//  AnimationController.swift
//  EMCamera
//
//  Created by Митько Евгений on 27.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit


class AnimationController {
 
    
    typealias DurationTuple = (fast: TimeInterval, medium: TimeInterval, slow: TimeInterval, halfSecond: TimeInterval)
    let duration: DurationTuple = (fast: 0.2, medium: 0.3, slow: 0.4, halfSecond: 0.5)
    
    internal func opacity(with duration: TimeInterval = 0.4, from: Float = 0, to: Float = 1, repeatForever: Bool = false, autoreverses: Bool = false) -> CABasicAnimation {
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        opacityAnimation.fromValue = from
        opacityAnimation.toValue = to
        opacityAnimation.repeatCount = repeatForever ? Float.greatestFiniteMagnitude : 0
        opacityAnimation.autoreverses = autoreverses
        return opacityAnimation
    }
    
    internal func scale(with duration: TimeInterval = 0.4, from: CGFloat = 0, to: CGFloat = 1, repeatForever: Bool = false, autoreverses: Bool = false) -> CABasicAnimation {
        let scaleAnimation = CABasicAnimation(keyPath: "transform")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = CATransform3DMakeScale(from, from, 1)
        scaleAnimation.toValue = CATransform3DMakeScale(to, to, 1)
        scaleAnimation.repeatCount = repeatForever ? Float.greatestFiniteMagnitude : 0
        scaleAnimation.autoreverses = autoreverses
        return scaleAnimation
    }
    
    internal func group(from animations: [CABasicAnimation]) -> CAAnimation {
        var duration = self.duration.medium
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

    internal func springTranslation(of view: UIView, to position: CGPoint, with duration: TimeInterval = 0.4, completion: ((Bool)->())? = nil) {
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            view.frame.origin = position
        }) { (finished) in
            completion?(finished)
        }
    }
    
    internal func springTranslation(of view: UIView, yTranslation: CGFloat, xTranslation: CGFloat, with duration: TimeInterval = 0.4, completion: ((Bool)->())? = nil) {
        let newCenter = CGPoint(x: view.frame.origin.x + xTranslation, y: view.frame.origin.y + yTranslation)
        springTranslation(of: view, to: newCenter, with: duration, completion: completion)
    }

}
