//
//  UserCell.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/13/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var avatarView: AvatarContainerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    var action: Closure<Void>?
    var hidesButton: Bool = false {
        didSet {
            buttonWidthConstraint.constant = hidesButton ? 0 : 85
            button.isHidden = hidesButton
        }
    }
    
    @IBAction func didPressButton(_ sender: UIButton) {
        action?()
    }
}
