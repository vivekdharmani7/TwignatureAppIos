//
//  TweetCell.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import ActiveLabel
import TwitterKit

enum TweetCellContentDestination {
	case tweet, retweet
}

class TweetCell: UITableViewCell {

	@IBOutlet weak var locationButtonView: UIButton!
	@IBOutlet private weak var replyImageView: UIImageView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
	@IBOutlet private weak var directMessageImageView: UIImageView!
	@IBOutlet weak var likeControl: UIControl!
	
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var tweetContentView: TweetContentView!
	@IBOutlet weak var retweetContentView: TweetContentView!

	private weak var possiblySensitiveView: UIView?
	
	var mediasViewHeightConstraintConstant: CGFloat?
	var tweetViewHeightConstraintConstant: CGFloat?

	weak var mediasView: MediasView!
    
    var replyTapCallback: Closure<Void>?
    var retweetTapCallback: Closure<Void>?
    var likeTapCallback: Closure<Void>?
    var messageTapCallback: Closure<Void>?
	var mediaTapCallback: Closure<(item: MediaItem, view: UIImageView)>?
    var hashtagTapCallback: Closure<String>?
    var mentionTapCallback: Closure<String>?
    var linkTapCallback: Closure<String>?
	var locationTapCallback: Closure<Void>?
	var profileTapCallback: Closure<TweetCellContentDestination>?
	var sealTapCallback: Closure<Void>?
	var longTapCallback: Closure<Void>?
	
	var isPossiblySensitive: Bool = true {
		didSet {
			if isPossiblySensitive && possiblySensitiveView == nil {
				let v = PossiblySensitiveTweetSubView.nibView()!
				v.pinToSuperview()
				possiblySensitiveView = v
				needToShowMedia(false, for: .tweet)
				needToShowMedia(false, for: .retweet)
			} else {
				possiblySensitiveView?.removeFromSuperview()
				possiblySensitiveView = nil
			}
		}
	}
	
    // MARK: - Lifecycle
    
	override func awakeFromNib() {
        super.awakeFromNib()		
	    configureLabel(tweetContentView)
		configureLabel(retweetContentView)
		tweetContentView.delegate = self
		retweetContentView.delegate = self
		
		let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongTap))
		self.addGestureRecognizer(longTapGesture)
		setImageDefaultImageColor(replyImageView)
		setImageDefaultImageColor(retweetImageView)
		setImageDefaultImageColor(likeImageView)
		setImageDefaultImageColor(directMessageImageView)
    }
	
	private func setImageDefaultImageColor(_ imageView: UIImageView) {
		imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
		imageView.tintColor = UIColor.tn_notLiked
	}
	
	dynamic
	private func didLongTap(gestureRecognizer: UILongPressGestureRecognizer) {
		guard gestureRecognizer.state == .began else { return }
		
		longTapCallback?()
	}
	
    override func prepareForReuse() {
        super.prepareForReuse()
		tweetContentView.tweetTextLabel.text = nil
		retweetContentView.tweetTextLabel.text = nil
		likeControl.isEnabled = true
        tweetContentView.mediasViewContainer.isHidden = false
		retweetContentView.mediasViewContainer.isHidden = false
		locationButtonView.setTitle("", for: .normal)
		isPossiblySensitive = false
    }
	
    // MARK: - Actions
    
    // MARK: - Private
    
    // MARK: - IBActions
    
    @IBAction fileprivate func replyDdiTap(_ sender: Any) {
        replyTapCallback?()
    }
    
    @IBAction fileprivate func retweetDidTap(_ sender: Any) {
        retweetTapCallback?()
    }
    
    @IBAction fileprivate func likeDidTap(_ sender: Any) {
        likeTapCallback?()
    }
    
    @IBAction fileprivate func messageDidTap(_ sender: Any) {
        messageTapCallback?()
    }
	
	@IBAction fileprivate func locationDidTap(_ sender: Any) {
		locationTapCallback?()
	}
	
	@IBAction fileprivate func profileDidTap(_ sender: Any) {
	}
	
	@IBAction fileprivate func sealDidTap(_ sender: Any) {
	}

	// MARK: - Configuration
	
	func needToShowMedia(_ needed: Bool, for destination: TweetCellContentDestination ) {
		var neededTweetInfoView: TweetContentView!
		switch destination {
			case .tweet:
				neededTweetInfoView = self.tweetContentView
			case .retweet:
				neededTweetInfoView = self.retweetContentView
		}
		neededTweetInfoView.needToShowMedia(needed)
	}
	
    private func configureLabel(_ tweetContentView: TweetContentView) {
		tweetContentView.replyToLabel.enabledTypes = [.mention]
		tweetContentView.replyToLabel.handleMentionTap { [weak self] (mention) in
			self?.mentionTapCallback?(mention)
		}
		tweetContentView.replyToLabel.mentionColor = tweetContentView.replyToLabel.textColor
		tweetContentView.tweetTextLabel.text = nil
		tweetContentView.tweetTextLabel.enabledTypes = [.hashtag, .mention, .url]
		tweetContentView.tweetTextLabel.hashtagColor = Color.link
		tweetContentView.tweetTextLabel.mentionColor = Color.link
		tweetContentView.tweetTextLabel.URLColor = Color.link
		tweetContentView.tweetTextLabel.handleURLTap { [weak self] (url) in
            self?.linkTapCallback?(url.absoluteString)
        }
		tweetContentView.tweetTextLabel.handleHashtagTap { [weak self] (hashtag) in
            self?.hashtagTapCallback?(hashtag)
        }
		tweetContentView.tweetTextLabel.handleMentionTap { [weak self] (mention) in
            self?.mentionTapCallback?(mention)
        }
    }
}

extension TweetCell: MediasViewDelegate {

	func itemAction(item: MediaItem, transitionImageView: UIImageView) {
		mediaTapCallback?((item, transitionImageView))
	}
}

extension TweetCell: TweetContentViewDelegate {
	func profileImagePressed(_ tweetContentView: TweetContentView) {
		let destination: TweetCellContentDestination = self.tweetContentView == tweetContentView ? .tweet : .retweet
		profileTapCallback?(destination)
	}

	func didPressSealButton(_ tweetContentView: TweetContentView) {
		sealTapCallback?()
	}
}