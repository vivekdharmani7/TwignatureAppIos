//
//  ActionTableViewCell.swift
//  Twignature
//
//  Created by mac on 13.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {

	@IBOutlet private weak var actionTitleLabel: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setTitle(_ title: String) {
		actionTitleLabel.text = title
	}
}
