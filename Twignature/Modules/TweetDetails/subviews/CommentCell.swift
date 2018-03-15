//
//  CommentCell.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/19/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ActiveLabel

class CommentCell: UITableViewCell {
	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var avatarView: AvatarContainerView!
	@IBOutlet private weak var userAndTimeLabel: UILabel!
	@IBOutlet private weak var replyToLabel: ActiveLabel!
	@IBOutlet private weak var tweetTextLabel: ActiveLabel!
	@IBOutlet private weak var retweetsLabel: UILabel!
	@IBOutlet private weak var likesLabel: UILabel!
	@IBOutlet private weak var mediaContainer: UIView!
	@IBOutlet private weak var replyImageView: UIImageView!
	@IBOutlet private weak var retweetImageView: UIImageView!
	@IBOutlet private weak var likeImageView: UIImageView!
	@IBOutlet private weak var directMessageImageView: UIImageView!
    @IBOutlet private weak var sealView: UIImageView!
    @IBOutlet private weak var sealBackgroundView: UIView!
    @IBOutlet private weak var sealButton: UIButton!
	
	@IBOutlet weak var possiblySensitiveContainer: UIControl!
	private weak var possiblySensitiveView: UIView?
	
	private var mediasView: MediasView!
	@IBOutlet weak var mediasHeightConstr: NSLayoutConstraint!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarDidTap))
		avatarView.addGestureRecognizer(tapGestureRecognizer)
		let titleGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarDidTap))
		titleLabel.addGestureRecognizer(titleGestureRecognizer)
		titleLabel.isUserInteractionEnabled = true
		let userAndTimeGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(avatarDidTap))
		userAndTimeLabel.addGestureRecognizer(userAndTimeGestureRecognizer)
		userAndTimeLabel.isUserInteractionEnabled = true
		
		mediasView = MediasView.nibView()
		mediaContainer.insertSubview(mediasView, at: 0)
		mediasView.pinToSuperview()
		mediasView.delegate = self
		configureLabel()
		setImageDefaultImageColor(replyImageView)
		setImageDefaultImageColor(retweetImageView)
		setImageDefaultImageColor(likeImageView)
		setImageDefaultImageColor(directMessageImageView)
		
		let longTapGestureture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap))
		self.addGestureRecognizer(longTapGestureture)
	}
	
	var coverPossiblySensitive: Bool = true {
		didSet {
			possiblySensitiveContainer.isHidden = !coverPossiblySensitive
			if coverPossiblySensitive {
				if possiblySensitiveView == nil {
					let v = PossiblySensitiveTweetSubView.nibView()!
					possiblySensitiveContainer.addSubview(v)
					v.pinToSuperview()
					possiblySensitiveView = v
				}
				tweetTextLabel.text = nil
				mediaEnabled = false
			} else {
				possiblySensitiveView?.removeFromSuperview()
				possiblySensitiveView = nil
			}
		}
	}
	
	dynamic
	private func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
		guard gestureRecognizer.state == .began else { return }
		guard let tweet = tweet else {
			return
		}
		delegate?.menuAction(tweet: tweet, withSender: self)
	}
	
	private func setImageDefaultImageColor(_ imageView: UIImageView) {
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = UIColor.tn_notLiked
	}
	
	private var mediaEnabled = false {
		didSet {
			mediaContainer.isHidden = !mediaEnabled
		}
	}
	private var secondaryMediaEnabled = false
	
	private func configureMediaView(tweet: Tweet) {
		if let extendedMedia = tweet.tweetInfo.extendedMedia {
			mediaEnabled = true
			mediasView.configureWith(mediaItems: extendedMedia)
			secondaryMediaEnabled = extendedMedia.count > 1
		} else {
			mediaEnabled = false
		}
		
		mediasHeightConstr.constant = type(of: self).mediaHeight * 0.5
			+ (secondaryMediaEnabled ? type(of: self).mediaHeight * 0.5 : 0)
		likeImageView.tintColor = tweet.isLiked ? UIColor.tn_liked: UIColor.tn_notLiked
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		avatarView.imageView.image = nil
		coverPossiblySensitive = false
	}
	
	weak var delegate: TweetUserInteractive?
	private(set) var tweet: Tweet?
	private var tweetId: TweetID? { return tweet?.id }
	
	func configureWith(replyTweet tweet: Tweet) {
		self.tweet = tweet
        if let seal = tweet.seal, let sealUrl = URL(string: "\(NetworkService.environment.imagesUrl)\(seal.imagePath)") {
            sealView.setImage(with: sealUrl)
        } else {
            sealButton.isHidden = true
            sealView.isHidden = true
            sealBackgroundView.isHidden = true
        }
		let createdTimeAgo = Date().offset(from: tweet.createdAt)
		let textAndNames = tweet.tweetInfo.extractTextAndReplyTo()
		let user = tweet.tweetInfo.user
		titleLabel.text = user.name
		replyToLabel.text = "answered to \(textAndNames.replyToNames)"
		userAndTimeLabel.text = "@\(user.screenName) , \(createdTimeAgo?.stringValue ?? "")"
        if user.isVerified {
            userAndTimeLabel.insert(image: #imageLiteral(resourceName: "ic_verified"), at: user.screenName.count + 2)
        }
		avatarView.imageView.setImage(with: user.profileImageUrl)
		retweetsLabel.text = String(tweet.retweetCount)
		retweetImageView.tintColor = tweet.isRetweeted ? UIColor.tn_liked : UIColor.tn_notLiked
		likesLabel.text = String(tweet.likesCount)
		likeImageView.tintColor = tweet.isLiked ? UIColor.tn_liked : UIColor.tn_notLiked
		
		coverPossiblySensitive = tweet.shouldBeCovered
		guard !coverPossiblySensitive else {
			return
		}
		
		tweetTextLabel.text = textAndNames.text
		configureMediaView(tweet: tweet)
	}
	
	private func configureLabel() {
		replyToLabel.enabledTypes = [.mention]
		replyToLabel.handleMentionTap { [weak self] (mention) in
			self?.handleMention(mention: mention)
		}
		replyToLabel.mentionColor = replyToLabel.textColor
		tweetTextLabel.enabledTypes = [.hashtag, .mention, .url]
		tweetTextLabel.hashtagColor = Color.link
		tweetTextLabel.mentionColor = Color.link
		tweetTextLabel.URLColor = Color.link
		tweetTextLabel.handleURLTap { [weak self] (url) in
			self?.delegate?.urlAction(url: url)
		}
		tweetTextLabel.handleHashtagTap { [weak self] (hashtag) in
			self?.delegate?.hashTagAction(tag: hashtag)
		}
		tweetTextLabel.handleMentionTap { [weak self] (mention) in
			self?.handleMention(mention: mention)
		}
	}
	
	private func handleMention(mention : String) {
		if let user = tweet?.tweetInfo.mentionedUsers.first(where: { $0.screenName == mention }) {
			self.delegate?.mentionAction(user: user)
		}
	}
	
	private static let initialHeight: CGFloat = 460
	private static let initialTextHeight: CGFloat = 24
	private static let leftTextMargin: CGFloat = 80
	private static let rightTextMargin: CGFloat = 24
	private static let mediaHeight: CGFloat = 300
	
	static func calculateHeightFor(with: CGFloat, andTweet tweet: Tweet) -> CGFloat {
		let textHeight: CGFloat
		var mediaEnabled = false
		var secondaryMediaEnabled = false
		if tweet.shouldBeCovered {
			textHeight = mediaHeight * 0.5
		} else {
			let (answers, strippedText) = tweet.tweetInfo.extractTextAndReplyTo()
			let textWidth = with - leftTextMargin - rightTextMargin
			let answersHeight = answers.sizeForText(forContainerWithWidth: textWidth, font: Font.SFUITextRegular(15.0)).height
			let strippedTextHeight = strippedText.sizeForText(forContainerWithWidth: textWidth,
					font: Font.SFUITextRegular(15.0)).height
			textHeight = strippedTextHeight + answersHeight

		
			let cnt = tweet.tweetInfo.extendedMedia?.count ?? 0
			mediaEnabled = cnt > 0
			secondaryMediaEnabled = cnt > 1
		}
		
		let h = initialHeight + textHeight - initialTextHeight
			- (mediaEnabled ? 0 : mediaHeight * 0.5)
			- (secondaryMediaEnabled ? 0 : mediaHeight * 0.5)
		return h
	}
	
	@IBAction func replyDidTap(_ sender: Any) {
		guard let tweet = tweet else { return }
		delegate?.replyAction(tweet: tweet)
	}
	
	@IBAction func retweetDidTap(_ sender: UIButton) {
		guard let tweet = tweet else { return }
		delegate?.retweetAction(tweet: tweet, withSender: sender)
	}
	
	@IBAction func likeDidTap(_ sender: Any) {
		guard let tweet = tweet else { return }
		delegate?.likeAction(tweet: tweet)
	}
	
	@IBAction func messageDidTap(_ sender: Any) {
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

extension CommentCell: MediasViewDelegate {
	func itemAction(item: MediaItem, transitionImageView: UIImageView) {
		delegate?.mediaAction(item: item, transitionImageView: transitionImageView)
	}
}
