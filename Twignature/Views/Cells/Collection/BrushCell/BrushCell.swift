//
//  BrushCell.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class BrushCell: UICollectionViewCell {

	@IBOutlet private weak var brushView: UIView!
	@IBOutlet private weak var brushHeightConstraint: NSLayoutConstraint!

	func setBrushRadius(_ radius: CGFloat) {
		guard radius > 0 else {
			fatalError("radius should be grater than 0")
		}
		self.brushView.cornerRadius = radius
		self.brushHeightConstraint.constant = radius * 2
	}

	func setBrushSelected(_ selected: Bool) {
		self.borderColor = selected ? .lightGray : .darkGray
	}
}
