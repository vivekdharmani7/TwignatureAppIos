//
//  MediasView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/25/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

protocol MediasViewDelegate: class {
	func itemAction(item: MediaItem, transitionImageView: UIImageView)
}

final class MediasView: UIView, NibLoadable {
	
	weak var delegate: MediasViewDelegate?
	
	@IBOutlet weak var primaryMediaItemView: MediaItemView!
	
	@IBOutlet private weak var secondaryItemsStack: UIStackView!
	
	@IBOutlet var secondaryItemsCollection: [MediaItemView]!
	
	private var mediaItems: [MediaItem]? {
		didSet {
			primaryMediaItemView.configureWith(item: primaryItem)
			
			guard let items = mediaItems, items.count > 1 else {
				secondaryItemsStack.isHidden = true
				return
			}
			
			var imageIx = 0
			for itemIx in 0...items.count - 2 {
				let item = items[itemIx]
				guard imageIx < secondaryItemsCollection.count else { break }
				secondaryItemsCollection[imageIx].configureWith(item: item)
				imageIx += 1
			}

			if imageIx < secondaryItemsCollection.count {
				for ix in imageIx...secondaryItemsCollection.count - 1 {
					secondaryItemsCollection[ix].isHidden = true
				}
			}
		}
	}
	
	private var image: UIImage? {
		didSet {
			guard let requiredImage = image else { return }
			primaryMediaItemView.configureWith(image: requiredImage)
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mainImageTapped))
		primaryMediaItemView.addGestureRecognizer(tapGestureRecognizer)
		for itemView in secondaryItemsCollection {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
			itemView.addGestureRecognizer(tapGestureRecognizer)
		}
		
		primaryMediaItemView.imageView.contentMode = .scaleAspectFill
	}
	
	dynamic
	private func mainImageTapped() {
		if let item = primaryItem {
			delegate?.itemAction(item: item, transitionImageView: primaryMediaItemView.imageView)
		}
	}
	
	dynamic
	private func itemTapped(sender: UIGestureRecognizer) {
		guard let mediaItems = mediaItems,
			let tappedView = sender.view as? MediaItemView,
			let ix = secondaryItemsCollection.index(of: tappedView) else {			
				return
		}
		let item = mediaItems[ix]
		delegate?.itemAction(item: item, transitionImageView: tappedView.imageView)
	}

	private var primaryItem : MediaItem? {
		return mediaItems?.last
	}
	
	func configureWith(mediaItems: [MediaItem]?) {
		self.mediaItems = mediaItems	
		secondaryItemsStack.isHidden = (mediaItems?.count ?? 0) < 2
	}

	func configureWith(image: UIImage) {
		self.image = image
		secondaryItemsStack.isHidden = true
	}
}
