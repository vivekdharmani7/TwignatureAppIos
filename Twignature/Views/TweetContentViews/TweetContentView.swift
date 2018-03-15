//
//  TweetContentView.swift
//  Twignature
//
//  Created by mac on 11.12.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ActiveLabel
import EasyPeasy

protocol TweetContentViewDelegate: MediasViewDelegate {
	func profileImagePressed(_ tweetContentView: TweetContentView)
	func didPressSealButton(_ tweetContentView: TweetContentView)
}

class TweetContentView: UIView {

    @IBOutlet weak var tweetTextLabel: ActiveLabel!
    @IBOutlet weak var avatarView: AvatarContainerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mediasViewContainer: UIView!
    @IBOutlet weak var mediasViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var possiblySensitiveContainer: UIView!
    private weak var possiblySensitiveView: UIView?
    @IBOutlet weak var replyToLabel: ActiveLabel!

	@IBOutlet weak var sealButton: UIButton!
    @IBOutlet weak var sealImageView: UIImageView!
    @IBOutlet weak var sealBackground: UIView!

    weak var contentView:UIView?
	weak var mediasView: MediasView!
	weak var delegate: TweetContentViewDelegate?

	@IBOutlet weak var contentContainerView: UIView!
	@IBOutlet weak var contentContainerViewBottomConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    var isPossiblySensitive: Bool = true {
        didSet {
			possiblySensitiveContainer.isHidden = !isPossiblySensitive
			possiblySensitiveView?.removeFromSuperview()
			possiblySensitiveView = nil
            if isPossiblySensitive && possiblySensitiveView == nil {
                let v = PossiblySensitiveTweetSubView.nibView()!
				possiblySensitiveContainer.addSubview(v)
                v.pinToSuperview()
                possiblySensitiveView = v
                needToShowMedia(false)
            }
        }
    }

	var needToShowContent: Bool = true {
		didSet {
			guard oldValue != self.needToShowContent else {
				return
			}
			var neededConstraint: [Attribute] = [needToShowContent ? Bottom(-8).to(self.contentContainerView, .bottom) : Bottom(-8).to(self.replyToLabel, .bottom) ]
			contentContainerViewBottomConstraint?.isActive = false
			let constraints = self.contentView?.easy.layout(neededConstraint)
			contentContainerViewBottomConstraint = constraints?.first
		}
	}

    private func commonInit() {
        guard let contentView = Bundle.main.loadNibNamed("TweetContentView", owner: self, options: nil)?.first as? UIView else {
            return
        }
        addSubview(contentView)
        contentView.pinToSuperview()
        self.contentView = contentView
    }
    
    func needToShowMedia(_ needed: Bool) {
        if needed {
            self.mediasViewHeightConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 660 : 190
            let mediasView = MediasView.nibView()!
            self.mediasView = mediasView
            self.mediasViewContainer.addSubview(mediasView)
            self.mediasView.pinToSuperview()
            self.mediasViewContainer.bringSubview(toFront: self.sealBackground)
            self.mediasViewContainer.bringSubview(toFront: self.sealImageView)
            self.mediasViewContainer.bringSubview(toFront: self.sealButton)
            self.mediasView.delegate = self.delegate
        } else {
            self.mediasView?.removeFromSuperview()
            self.mediasView = nil
            self.mediasViewHeightConstraint.constant = 0
        }
    }

	func focusOnSensitiveContentView() {
		contentContainerViewBottomConstraint?.isActive = false
	}

	@IBAction func didPressProfileButton(_ sender: Any) {
		self.delegate?.profileImagePressed(self)
	}

	@IBAction func didPressSealButton(_ sender: Any) {
		self.delegate?.didPressSealButton(self)
	}
}
