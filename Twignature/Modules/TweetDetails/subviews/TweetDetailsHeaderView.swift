//
//  TweetDetailsHeaderView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/22/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ActiveLabel
import EasyPeasy

final class TweetDetailsHeaderView: UIView, NibLoadable {

    @IBOutlet private weak var tweetContentView: TweetContentView!
    @IBOutlet private weak var retweetContentView: TweetContentView!
	@IBOutlet private weak var dateLabel: UILabel!
	@IBOutlet private weak var retweetsLabel: UILabel!
	@IBOutlet private weak var likesLabel: UILabel!
	@IBOutlet weak var likeButton: UIButton!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		configureLabel(for: tweetContentView)
		configureLabel(for: retweetContentView)
		tweetContentView.delegate = self
		retweetContentView.delegate = self
		let modifiedLikeImage = likeButton.image(for: .normal)?.withRenderingMode(.alwaysTemplate)
		likeButton.setImage(modifiedLikeImage, for: .normal)
		let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap))
		self.addGestureRecognizer(longTapGesture)
	}
	
	dynamic
	private func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
		guard gestureRecognizer.state == .began else { return }
		guard let tweet = tweet else { return }
		delegate?.menuAction(tweet: tweet, withSender: self)
	}

	weak var delegate: TweetUserInteractive?
	private(set) var tweet: Tweet?
	private var tweetId: TweetID? { return tweet?.id }
	
	func configureWith(replyTweet tweet: Tweet) {
		self.tweet = tweet
		TweetCellConfigurator.setupTweetInfoView(tweetContentView, withInfo: tweet.tweetInfo)
		tweetContentView.needToShowContent = true
		if let retweetInfo = tweet.retweetInfo {
			TweetCellConfigurator.setupTweetInfoView(self.retweetContentView, withInfo: retweetInfo)
			tweetContentView.needToShowContent = !(tweet.tweetInfo.text.isEmpty && !(tweet.tweetInfo.possiblySensitive ?? false))
		}
		let retweetContentView = self.retweetContentView.contentView!
		retweetContentView.removeFromSuperview()
		self.retweetContentView.addSubview(retweetContentView)
		var baseConstraint: [Attribute] = [Leading(), Trailing(), Top()]
		if tweet.retweetInfo != nil {
			baseConstraint.append(Bottom())
		}
		retweetContentView.easy.layout(baseConstraint)

		retweetsLabel.text = String(tweet.retweetCount)
		likesLabel.text = String(tweet.likesCount)
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = Format.Date.fullForTwitterDetails
		dateLabel.text = dateFormatter.string(from: tweet.createdAt)
		likeButton.tintColor = tweet.isLiked ? UIColor.tn_liked: UIColor.tn_notLiked

		updateMediaViews(tweet)
	}

	func updateMediaViews(_ tweet: Tweet) {
		//reset
		self.tweetContentView?.needToShowMedia(false)
		self.retweetContentView?.needToShowMedia(false)
		//content
		let destination: TweetCellContentDestination = tweet.retweetInfo != nil ? .retweet: .tweet
		var tweetContentView: TweetContentView? = destination == .retweet ? self.retweetContentView: self.tweetContentView
		var tweetInfo: TweetInfo? = destination == .retweet ? tweet.retweetInfo: tweet.tweetInfo
		tweetContentView?.needToShowMedia(tweetInfo?.extendedMedia != nil)
		let canBeNotCovered = !(tweet.retweetInfo?.possiblySensitive ?? tweet.tweetInfo.possiblySensitive ?? false) || (Session.current?.user.shouldDisplaySensetiveContent ?? false)
		guard canBeNotCovered else {
			return
		}
		if let extendedMedia = tweetInfo?.extendedMedia {
			tweetContentView?.mediasViewContainer.isHidden = false
			tweetContentView?.mediasView.configureWith(mediaItems: extendedMedia)
			guard let seal = tweet.seal, let sealUrl = URL(string: "\(NetworkService.environment.imagesUrl)\(seal.imagePath)") else {
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
	
	private var initialHeight: CGFloat {
		return 240 + mediaHeight
	}
	private var mediaHeight: CGFloat {
		return UIDevice.current.userInterfaceIdiom == .pad ? 640 : 170
	}
	private let initialTextHeight: CGFloat = 24
	private let leftTextMargin: CGFloat = 80
	private let rightTextMargin: CGFloat = 24	
	private let replyToHeight: CGFloat = 20
	
	func getDesiredHeightFor(with: CGFloat) -> CGFloat {
		return self.systemLayoutSizeFitting(CGSize(width: with, height: .infinity)).height
	}
	
	private func configureLabel(for tweetView: TweetContentView) {
		tweetView.replyToLabel.enabledTypes = [.mention]
		tweetView.replyToLabel.handleMentionTap { [weak self] (mention) in
			self?.handleMention(mention: mention)
		}
		tweetView.replyToLabel.mentionColor = tweetView.replyToLabel.textColor
		tweetView.tweetTextLabel.enabledTypes = [.hashtag, .mention, .url]
		tweetView.tweetTextLabel.hashtagColor = Color.link
		tweetView.tweetTextLabel.mentionColor = Color.link
		tweetView.tweetTextLabel.URLColor = Color.link
		tweetView.tweetTextLabel.handleURLTap { [weak self] (url) in
			self?.delegate?.urlAction(url: url)
		}
		tweetView.tweetTextLabel.handleHashtagTap { [weak self] (hashtag) in
			self?.delegate?.hashTagAction(tag: hashtag)
		}
		tweetView.tweetTextLabel.handleMentionTap { [weak self] (mention) in
			self?.handleMention(mention: mention)
		}
	}
	
	private func handleMention(mention : String) {
		if let user = tweet?.tweetInfo.mentionedUsers.first(where: { $0.screenName == mention }) {
			self.delegate?.mentionAction(user: user)
		}
	}
	
	@IBAction private func replyDidTap(_ sender: Any) {
		guard let tweet = tweet else { return }
		delegate?.replyAction(tweet: tweet)
	}
	
	@IBAction private func retweetDidTap(_ sender: UIButton) {
		guard let tweet = tweet else { return }
		delegate?.retweetAction(tweet: tweet, withSender: sender)
	}
	
	@IBAction private func likeDidTap(_ sender: Any) {
		guard let tweet = tweet else { return }
		delegate?.likeAction(tweet: tweet)
	}
	
	@IBAction private func messageDidTap(_ sender: Any) {
		guard let tweet = tweet else { return }
		delegate?.messageAction(tweet: tweet)
	}
    
    @IBAction func sealDidTap(_ sender: Any) {
        guard let tweet = tweet else { return }
        delegate?.sealAction(tweet: tweet)
    }

	dynamic
	private func avatarDidTap() {
		guard let user = tweet?.tweetInfo.user else {
			return
		}
		delegate?.avatarAction(user: user)
	}
}

extension TweetDetailsHeaderView: MediasViewDelegate {
	func itemAction(item: MediaItem, transitionImageView: UIImageView) {
		delegate?.mediaAction(item: item, transitionImageView: transitionImageView)
	}
}

extension TweetDetailsHeaderView: TweetContentViewDelegate {
	func profileImagePressed(_ tweetContentView: TweetContentView) {

	}

	func didPressSealButton(_ tweetContentView: TweetContentView) {
		guard let tweet = tweet else { return }
		delegate?.sealAction(tweet: tweet)
	}
}