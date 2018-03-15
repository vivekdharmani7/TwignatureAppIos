//
//  UIStackViewExtension.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

extension UIStackView {
    func animateContent(duration: TimeInterval, shift: CGFloat = 0) {
        let translate = "translate"
        let inset = bounds.width / CGFloat(subviews.count)
        subviews.forEach { view in
            view.layer.removeAnimation(forKey: translate)
            let speed = (bounds.maxX + inset + shift) / CGFloat(duration)
            
            let initialPosition = CATransform3DTranslate(view.layer.transform, -view.frame.maxX, 0, 0)
            let finalPosition = CATransform3DTranslate(initialPosition,
                                                       bounds.maxX + inset + shift, 0, 0)
            let initialDelta = bounds.maxX - (view.frame.maxX + inset + shift)
            let initialDuration = TimeInterval(initialDelta / speed)
            UIView.animate(withDuration: initialDuration, delay: 0, options: [.curveLinear], animations: {
                view.transform = view.transform.translatedBy(x: initialDelta, y: 0)
            }, completion: { _ in
                view.transform = CGAffineTransform.identity
                let translateAnimation = CABasicAnimation(keyPath: "transform")
                translateAnimation.repeatCount = Float.greatestFiniteMagnitude
                translateAnimation.duration = Double(duration)
                translateAnimation.fromValue = NSValue(caTransform3D: initialPosition)
                translateAnimation.toValue = NSValue(caTransform3D: finalPosition)
                view.layer.add(translateAnimation, forKey: translate)
            })
        }
    }
}
