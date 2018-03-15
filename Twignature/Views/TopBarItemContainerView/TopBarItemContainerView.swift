//
//  TopBarItemContainerView.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/19/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class TopBarItemContainerView: TopBarItemView, NibLoadable {

    @IBOutlet weak var avatarContainer: AvatarContainerView!
    
    override var image: UIImage? {
        didSet {
            avatarContainer.imageView.image = image
        }
    }
    
    override var selected: Bool {
        didSet {
            avatarContainer.tintColor = selected ? Color.twitterBlue : UIColor.clear
        }
    }

}
