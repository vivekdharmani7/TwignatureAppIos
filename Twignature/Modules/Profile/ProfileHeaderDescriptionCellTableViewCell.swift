//
//  ProfileHeaderDescriptionCellTableViewCell.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/28/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ProfileHeaderDescriptionCellTableViewCell: UITableViewCell {
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var linkButton: UIButton!
	
	func configure(header: ProfileViewController.HeaderViewModel) {
		descriptionLabel.text = header.description
		linkButton.setTitle(header.profileUrlDisplay, for: .normal)
	}
	
	func calculateHeight() -> CGFloat {
		var retHeight: CGFloat = 0
		if let description = descriptionLabel.text, !description.isEmpty {
			let yMargin: CGFloat = 25
			let xMargin: CGFloat = 50
			let sz = CGSize(width: self.frame.width - xMargin,
			                height: CGFloat.greatestFiniteMagnitude)
			let textHeight: CGFloat = descriptionLabel.sizeThatFits(sz).height
			retHeight = yMargin + textHeight
		}
		
		if let site = linkButton.titleLabel?.text, !site.isEmpty {
			retHeight += 30
			linkButton.setTitle(site, for: .normal)
		}
		
		return retHeight
	}
	
	func setToBlockedState(blockedBy: String) {
		descriptionLabel.text = "You are blocked from following \(blockedBy) and viewing \(blockedBy)'s Tweets."
		linkButton.isHidden = true
	}
	
}
