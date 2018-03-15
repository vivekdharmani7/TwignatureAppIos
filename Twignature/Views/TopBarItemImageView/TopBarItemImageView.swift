//
//  TopBarItemImageView.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/19/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class TopBarItemImageView: TopBarItemView, NibLoadable {

    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    override var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override var selected: Bool {
        didSet {
            imageView.tintColor = selected ? Color.twitterBlue : Color.lightGray
        }
    }
}
