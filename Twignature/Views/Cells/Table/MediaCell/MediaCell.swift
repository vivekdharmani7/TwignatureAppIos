//
//  MediaCell.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import Kingfisher

private let cellInset: CGFloat = Layout.mediaCellSpacing

class MediaCell: UITableViewCell {

	weak var delegate: MediasViewDelegate?
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
	var mediaItems: [MediaItem] = [] {
		didSet {
			collectionView.reloadData()
		}
	}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(R.nib.mediaItemCell)
    }
}

extension MediaCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let identifier = R.nib.mediaItemCell.identifier
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? MediaItemCell else {
			return UICollectionViewCell()
		}
        cell.configureWith(item: mediaItems[indexPath.row])
        return cell
    }
}

extension MediaCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - cellInset * 4) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellInset
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellInset, left: cellInset, bottom: cellInset, right: cellInset)
    }
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let cell = collectionView.cellForItem(at: indexPath) as? MediaItemCell,
		let mediaItem = cell.mediaItem else {
			return
		}
		
		delegate?.itemAction(item: mediaItem, transitionImageView: cell.imageView)
	}
}
