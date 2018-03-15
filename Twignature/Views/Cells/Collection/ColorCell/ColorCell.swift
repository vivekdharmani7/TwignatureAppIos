//
//  ColorCell.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {

	@IBOutlet private weak var colorView: UIView!

	func setColor(_ color: UIColor) {
		colorView.backgroundColor = color
	}
}
