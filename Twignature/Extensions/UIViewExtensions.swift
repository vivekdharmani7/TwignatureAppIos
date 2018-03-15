//
//  UIViewExtensions.swift
//  Twignature
//
//  Created by Ivan Hahanov on 5/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
extension UIView {
    @IBInspectable var shadowColor: UIColor? {
        set { layer.shadowColor = newValue?.cgColor }
        get { return layer.shadowColor.flatMap({ UIColor(cgColor: $0) }) }
    }
    
    @IBInspectable var shadowOpacity: Float {
        set { layer.shadowOpacity = newValue }
        get { return layer.shadowOpacity }
    }
    
    @IBInspectable var shadowRadius: CGFloat {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    @IBInspectable var xOffset: Double {
        set { layer.shadowOffset = CGSize(width: newValue, height: Double(layer.shadowOffset.width)) }
        get { return Double(layer.shadowOffset.width) }
    }
    
    @IBInspectable var yOffset: Double {
        set { layer.shadowOffset = CGSize(width: Double(layer.shadowOffset.height), height:  newValue) }
        get { return Double(layer.shadowOffset.height) }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set { layer.cornerRadius = newValue }
        get { return layer.cornerRadius }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set { layer.borderWidth = newValue }
        get { return layer.borderWidth }
    }
    
    @IBInspectable var maskToBounds: Bool {
        set { layer.masksToBounds = newValue }
        get { return layer.masksToBounds }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set { layer.borderColor = newValue?.cgColor }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
    
    @IBInspectable var roundedCorners: Bool {
        set {
            self.clipsToBounds = true
            self.cornerRadius = newValue ? self.bounds.height / 2 : 0
        } get {
            return self.cornerRadius == self.bounds.height / 2
        }
    }

    func pinToSuperview() {
        guard let superview = superview else { return }
		translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }
    
    func configureShadow(color: UIColor = .black,
                         opacity: Float = 0.5,
                         xOffset: Double = 0,
                         yOffset: Double = 10,
                         radius: CGFloat = 30) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        layer.shadowRadius = radius
        layer.masksToBounds = false
    }
		
	/// Create snapshot
	///
	/// - parameter rect: The `CGRect` of the portion of the view to return. If `nil` (or omitted),
	///                   return snapshot of the whole view.
	///
	/// - returns: Returns `UIImage` of the specified portion of the view.
	
	func snapshot(of rect: CGRect? = nil) -> UIImage? {
		// snapshot entire view
		
		UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0)
		drawHierarchy(in: bounds, afterScreenUpdates: true)
		let wholeImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		// if no `rect` provided, return image of whole view
		
		guard let image = wholeImage, let rect = rect else { return wholeImage }
		
		// otherwise, grab specified `rect` of image
		
		let scale = image.scale
		let scaledRect = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.size.width * scale, height: rect.size.height * scale)
		guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
		return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
	}
}

extension UIView: Identifierable, NibProvider { }

extension UILabel {
    func add(image: UIImage) {
        self.attributedText = "\(text ?? "") ".attributed
            .font(font)
            .color(textColor)
            .image(image)
    }
    
    func insert(image: UIImage, at pos: Int) {
        self.attributedText = "\(text ?? "") ".attributed
            .font(font)
            .color(textColor)
            .image(image, at: pos)
    }
}
