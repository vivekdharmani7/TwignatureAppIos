//
//  TweetDetailsFooterView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/22/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class TweetDetailsFooterView: UIView, NibLoadable {
	@IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var button: UIButton!
	
	var action: Closure<Void>?
	
	var inprogress: Bool = false {
		didSet {
			if inprogress {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
			button.isHidden = inprogress
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		button.layer.shadowColor = UIColor.gray.cgColor
		button.layer.shadowOffset = CGSize(width: 0, height: 5)
		button.layer.masksToBounds = false
		button.layer.shadowOpacity = Layout.defaultShadowOpacity
		activityIndicator.hidesWhenStopped = true
	}
	
	@IBAction private func didTap(_ sender: Any) {
		action?()
	}	
}
