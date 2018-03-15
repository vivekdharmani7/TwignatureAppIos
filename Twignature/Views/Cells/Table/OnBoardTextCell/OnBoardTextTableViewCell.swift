//
//  OnBoardTextTableViewCell.swift
//  Twignature
//
//  Created by mac on 15.09.17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class OnBoardTextTableViewCell: UITableViewCell {
	
	@IBOutlet private var label: UILabel!

	func setLabelText(_ text: String) {
		label.text = text
	}
    
}
