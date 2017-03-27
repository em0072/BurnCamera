//
//  StyleKit.swift
//  EMCamera
//
//  Created by Митько Евгений on 15.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit



class StyleKit: NSObject
{
    //MARK: - Canvas Drawings
    
    /// ArrowIcon
    
    class func drawArrowIcon2(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 40, height: 40), resizing: ResizingBehavior = .aspectFit)
    {
        /// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        /// Resize to Target Frame
        context.saveGState()
        let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 40, height: 40), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 40, y: resizedFrame.height / 40)
        
        /// Arrow
        let arrow = UIBezierPath()
        arrow.move(to: CGPoint(x: 10, y: 0))
        arrow.addCurve(to: CGPoint(x: 8.65, y: 0.47), controlPoint1: CGPoint(x: 9.39, y: -0), controlPoint2: CGPoint(x: 8.65, y: 0.47))
        arrow.addLine(to: CGPoint(x: 0.56, y: 5.22))
        arrow.addCurve(to: CGPoint(x: 1.91, y: 7.89), controlPoint1: CGPoint(x: -0.79, y: 5.89), controlPoint2: CGPoint(x: 0.56, y: 8.56))
        arrow.addLine(to: CGPoint(x: 10, y: 3.28))
        arrow.addLine(to: CGPoint(x: 18.09, y: 7.89))
        arrow.addCurve(to: CGPoint(x: 19.44, y: 5.22), controlPoint1: CGPoint(x: 19.44, y: 8.56), controlPoint2: CGPoint(x: 20.79, y: 5.89))
        arrow.addLine(to: CGPoint(x: 11.35, y: 0.47))
        arrow.addCurve(to: CGPoint(x: 10, y: 0), controlPoint1: CGPoint(x: 11.35, y: 0.47), controlPoint2: CGPoint(x: 10.61, y: 0))
        arrow.close()
        arrow.move(to: CGPoint(x: 10, y: 0))
        context.saveGState()
        context.translateBy(x: 10, y: 16)
        arrow.usesEvenOddFillRule = true
        UIColor(white: 1, alpha: 0.6).setFill()
        arrow.fill()
        context.restoreGState()
        
        context.restoreGState()
    }
    
    
    //MARK: - Canvas Images
    
    /// ArrowIcon
    
    class func imageOfArrowIcon2() -> UIImage
    {
        struct LocalCache
        {
            static var image: UIImage!
        }
        if LocalCache.image != nil
        {
            return LocalCache.image
        }
        var image: UIImage
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 40, height: 40), false, 0)
        StyleKit.drawArrowIcon2()
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        LocalCache.image = image
        return image
    }
    
    
    //MARK: - Resizing Behavior
    
    enum ResizingBehavior
    {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.
        
        func apply(rect: CGRect, target: CGRect) -> CGRect
        {
            if rect == target || target == CGRect.zero
            {
                return rect
            }
            
            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)
            
            switch self
            {
            case .aspectFit:
                scales.width = min(scales.width, scales.height)
                scales.height = scales.width
            case .aspectFill:
                scales.width = max(scales.width, scales.height)
                scales.height = scales.width
            case .stretch:
                break
            case .center:
                scales.width = 1
                scales.height = 1
            }
            
            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
    
}

