//
//  BlurredRoundedButton.swift
//  EMCamera
//
//  Created by Митько Евгений on 15.03.17.
//  Copyright © 2017 Evgeny Mitko. All rights reserved.
//

import UIKit


class BlurredRoundedButton: UIButton {
    let highlightedColor = UIColor(white: 0.3, alpha: 0.8)
    
    let effectBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    private func commonInit()  {
        initLayer()
        initEffectView()
    }
    private func initLayer() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = self.frame.width / 2
        layer.masksToBounds = false
    }
    private func initEffectView() {
        effectBackground.frame = bounds
        effectBackground.layer.cornerRadius = self.frame.width / 2
        effectBackground.layer.masksToBounds = true
        addSubview(effectBackground)
        sendSubview(toBack: effectBackground)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        print("touchesBegan")
        self.backgroundColor = highlightedColor
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        print("touchesMoved")
        if let touch = touches.first {
            let point = touch.location(in: self.superview)
            print("x: \(point.x), y: \(point.y)")
            if self.frame.contains(point) {
                self.backgroundColor = highlightedColor
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        print("touchesEnded")
        self.backgroundColor = .clear
        if let touch = touches.first {
            let point = touch.location(in: self.superview)
            if self.frame.contains(point) {
                self.sendActions(for: .touchUpInside)
            } else {
                self.sendActions(for: .touchUpOutside)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        print("touchesCancelled")
        self.backgroundColor = .clear
    }
    
    
}
