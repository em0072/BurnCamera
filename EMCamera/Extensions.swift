//
//  Extensions.swift
//  EMCamera
//
//  Created by Митько Евгений on 26.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit


extension UIView {
    func addShadow(color: UIColor = .black, offset: CGSize = .zero, radius: CGFloat = 3, opacity: Float = 0.7) {
        self.layer.addShadow(color: color, offset: offset, radius: radius, opacity: opacity)
    }
    
    func animateAlpha(to amount: CGFloat, time: TimeInterval = 0.2, completion: ((Bool)->())? = nil) {
        UIView.animate(withDuration: time, animations: {
            self.alpha = amount
        }, completion: { (finished) in
            completion?(finished)
        })

    }
}


extension CALayer {
    func addShadow(color: UIColor = .black, offset: CGSize = .zero, radius: CGFloat = 3, opacity: Float = 0.7) {
        self.shadowColor = color.cgColor
        self.shadowOffset = offset
        self.shadowRadius = radius
        self.shadowOpacity = opacity

    }
}

extension CGFloat {
    mutating func round(to decimal: Int) -> CGFloat {
        var number = Float(self)
        if decimal >= 0 {
            if decimal == 0 {
                return CGFloat(roundf(number))
            } else {
                var decimalInt = 1
                for _ in 1...decimal {
                    decimalInt = decimalInt * 10
                }
                number = number * Float(decimalInt)
                number = roundf(number)
                number = number / Float(decimalInt)
                return CGFloat(number)
            }
        }
        return CGFloat(number)
    }
}
