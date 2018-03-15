//
//  ExpendingTableViewCell.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ExpendingTableViewCell: UITableViewCell {

	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var buttonImageView: UIImageView!
	@IBOutlet private weak var containerView: UIView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
	
	private func setOpenedState() {
		buttonImageView.image = #imageLiteral(resourceName: "hideButton")
		containerView.backgroundColor = UIColor(red: 0/255.0, green: 195/255.0, blue: 255/255.0, alpha: 1.0)
		titleLabel.textColor = .white
	}
	
	private func setClosedState() {
		buttonImageView.image = #imageLiteral(resourceName: "showButton")
		containerView.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
		titleLabel.textColor = .black
	}
	
	func setStateAsExpended(_ asExpended: Bool) {
		if asExpended {
			setOpenedState()
		} else {
			setClosedState()
		}
	}
}
