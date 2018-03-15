//
//  DesignableTextField.swift
//  Twignature
//
//  Created by mac on 01.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class DesignableTextField: UITextField {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

	@IBInspectable var xInset: CGFloat = 0
	@IBInspectable var yInset: CGFloat = 0
	
	@IBInspectable var leftInset: CGFloat = 0
	@IBInspectable var rightInset: CGFloat = 0
	@IBInspectable var topInset: CGFloat = 0
	@IBInspectable var bottomInset: CGFloat = 0
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: xInset, dy: yInset)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		let rect = super.editingRect(forBounds: bounds)
		let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
		return UIEdgeInsetsInsetRect(rect, insets);
	}
}
