//
//  MediaItemView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/27/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class MediaItemView: ViewWithXib {
	
	@IBOutlet private(set) weak var imageView: UIImageView!
	
	@IBOutlet private weak var playIconView: UIView!
	
	func configureWith(item: MediaItem?) {
		imageView.setImage(with: item?.mediaUrl)
		playIconView.isHidden = item?.videoInfo == nil
	}
	
	func configureWith(image: UIImage?) {
		imageView.image = image
		playIconView.isHidden = true
	}
}
