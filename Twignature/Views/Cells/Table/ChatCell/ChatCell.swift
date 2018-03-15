//
//  ChatCell.swift
//  Twignature
//
//  Created by Anton Muratov on 9/14/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
    @IBOutlet weak var avatarView: AvatarContainerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageTextLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
}
