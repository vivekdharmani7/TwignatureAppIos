//
//  TweetCellConfigurator.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 11/8/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import EasyPeasy

class TweetCellConfigurator {

	static func setupFields(for tweetCell: TweetCell, with viewModelItem: FeedViewModel.TweetViewItem, indexPath: IndexPath) {
		TweetCellConfigurator.setupTweetInfoView(tweetCell.tweetContentView, withInfo: viewModelItem.tweetInfo)
		tweetCell.tweetContentView.needToShowContent = true
		if let retweetInfo = viewModelItem.retweetInfo {
			TweetCellConfigurator.setupTweetInfoView(tweetCell.retweetContentView, withInfo: retweetInfo)
			tweetCell.tweetContentView.needToShowContent = !(viewModelItem.tweetInfo.text.isEmpty && !(viewModelItem.tweetInfo.possiblySensitive ?? false))
		}
		let retweetContentView = tweetCell.retweetContentView.contentView!
		retweetContentView.removeFromSuperview()
		tweetCell.retweetContentView.addSubview(retweetContentView)
		var baseConstraint: [Attribute] = [Leading(), Trailing(), Top()]
		if viewModelItem.retweetInfo != nil {
			baseConstraint.append(Bottom())
		}
		retweetContentView.easy.layout(baseConstraint)

		tweetCell.retweetsCountLabel.text = viewModelItem.retweetsCount
		tweetCell.likesCountLabel.text = viewModelItem.likesCount
		tweetCell.likeImageView.tintColor = viewModelItem.isLiked ? UIColor.tn_liked : UIColor.tn_notLiked
		tweetCell.retweetImageView.tintColor = viewModelItem.isRetweeted ? UIColor.tn_liked : UIColor.tn_notLiked
		tweetCell.locationButtonView.isHidden = viewModelItem.location == nil
		tweetCell.locationButtonView.setTitle(viewModelItem.locationFullName, for: .normal)
		//setup time
		let createdTimeAgo = Date().offset(from: viewModelItem.createdAt)
		tweetCell.dateLabel.text = "\(createdTimeAgo?.stringValue ?? "") ago"

	}

	static func setupTweetInfoView(_ infoView: TweetContentView, withInfo info: TweetInfo) {
		infoView.nameLabel.text = info.user.name
		infoView.usernameLabel.text = "@\(info.user.screenName)"
		if info.user.isVerified {
			infoView.usernameLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
		}
		infoView.isPossiblySensitive = (info.possiblySensitive ?? false) && !(Session.current?.user.shouldDisplaySensetiveContent ?? false)
		infoView.avatarView.imageView.setImage(with: info.user.profileImageUrl)
		let textAndReplyTo: (replyToNames: String, text: String) = info.extractTextAndReplyTo()
		let names: String = textAndReplyTo.replyToNames
		infoView.replyToLabel.text = names.isEmpty ? "": "answered to " + names
		infoView.tweetTextLabel.text = textAndReplyTo.text

	}

	static func setupImage(for tweetCell: TweetCell,
					with viewModelItem: FeedViewModel.TweetViewItem,
					at indexPath: IndexPath,
					tableView: UITableView) {

		tweetCell.needToShowMedia(false, for: .tweet)
		tweetCell.needToShowMedia(false, for: .retweet)
		let destination: TweetCellContentDestination = viewModelItem.retweetInfo != nil ? .retweet: .tweet
		var tweetContentView: TweetContentView? = destination == .retweet ? tweetCell.retweetContentView: tweetCell.tweetContentView
		var tweetInfo: TweetInfo? = destination == .retweet ? viewModelItem.retweetInfo: viewModelItem.tweetInfo
		tweetCell.needToShowMedia(tweetInfo?.extendedMedia != nil, for: destination)
		if destination == .retweet {
			tweetCell.needToShowMedia(false, for: .tweet)
		}
		let canBeNotCovered = !(viewModelItem.retweetInfo?.possiblySensitive ?? viewModelItem.tweetInfo.possiblySensitive ?? false) || (Session.current?.user.shouldDisplaySensetiveContent ?? false)
		guard canBeNotCovered else {
			return
		}
		if let extendedMedia = tweetInfo?.extendedMedia {
			tweetContentView?.mediasViewContainer.isHidden = false
			tweetContentView?.mediasView.configureWith(mediaItems: extendedMedia)
			guard let seal = viewModelItem.seal, let sealUrl = URL(string: "\(NetworkService.environment.imagesUrl)\(seal.imagePath)") else {
				tweetContentView?.sealButton.isHidden = true
				tweetContentView?.sealImageView.isHidden = true
				tweetContentView?.sealBackground.isHidden = true
				return
			}
			tweetContentView?.sealImageView.kf.setImage(with: sealUrl)
			tweetContentView?.sealImageView.isHidden = false
			tweetContentView?.sealButton.isHidden = false
			tweetContentView?.sealBackground.isHidden = false
			tweetContentView?.sealButton.imageView?.kf.setImage(with: sealUrl)
		} else {
			tweetContentView?.sealButton.isHidden = true
			tweetContentView?.sealImageView.isHidden = true
			tweetContentView?.mediasViewContainer.isHidden = true
			tweetContentView?.sealBackground.isHidden = true
		}
	}
}
