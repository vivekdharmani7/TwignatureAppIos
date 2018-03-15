//
//  MediaItemCell.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class MediaItemCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var playIconView: UIView!
	private(set) var mediaItem: MediaItem?
	
	func configureWith(item: MediaItem) {
		mediaItem = item
		imageView.setImage(with: item.mediaUrl)
		playIconView.isHidden = item.videoInfo == nil
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = Color.defaultShadow.cgColor
        layer.shadowOpacity = Layout.defaultShadowOpacity
        layer.shadowRadius = Layout.defaultShadowRadius
        layer.shadowOffset = Layout.defaultShadowOffset
        layer.masksToBounds = false
        imageView.cornerRadius = Layout.floatCellCornerRadius
        imageView.clipsToBounds = true
		
    }
}
