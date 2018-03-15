//
//  SealDetailsViewController.swift
//  Twignature
//
//  Created by mac on 04.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SealDetailsViewController: UIViewController {
    //MARK: - Properties
    var presenter: SealDetailsPresenter!
	var sealDetailsTableViewController: SealDetailsTableViewController? {
		return self.childViewControllers.first(where: { (childController) -> Bool in
			return childController is SealDetailsTableViewController
		}) as? SealDetailsTableViewController
	}
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		presenter.viewIsReady()
        configureInterface()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
	
	//MARK: - IBACTION
	
	@IBAction fileprivate func backDidTap(_ sender: Any) {
		presenter.backButtonAction()
	}
	
	//MARK: - PUBLIC
	
	func updateWithModel(_ tweetViewModel: SealDetailsViewModel) {
		updateUserFields(tweetViewModel)
		updateTweetFields(tweetViewModel)
		updateSealFields(tweetViewModel.seal)
		sealDetailsTableViewController?.shareButtonActionHandler = { [weak self] in
			print("some action")
			self?.presenter.shareButtonAction()
		}
		sealDetailsTableViewController?.urlHandler = { [weak self] (url) in
			self?.presenter.linkAction(url)
		}
	}
	
	func updateUserFields(_ tweetViewModel: SealDetailsViewModel) {
		sealDetailsTableViewController?.profileNameLabel.text = tweetViewModel.authorName
		sealDetailsTableViewController?.profileScreenNameLabel.text = tweetViewModel.authorTweeterName
		guard let imageUrl = tweetViewModel.authorAvatarUrl else {
			return
		}
		sealDetailsTableViewController?.profileImageView.kf.setImage(with: imageUrl)
	}
	
	func updateTweetFields(_ tweetViewModel: SealDetailsViewModel) {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = Format.Date.monthDayYear
		sealDetailsTableViewController?.sealDateLabel.text = dateFormatter.string(from: tweetViewModel.createdAt)
		sealDetailsTableViewController?.sealTweetIdLabel.text = "#\(tweetViewModel.signId)"
		sealDetailsTableViewController?.sealPlaceLabel.text = tweetViewModel.locationFullName ?? "Undefined"
		sealDetailsTableViewController?.sealPlaceLabel.isHidden = tweetViewModel.locationFullName == nil
		if tweetViewModel.locationFullName == nil {
			sealDetailsTableViewController?.placeToBottomCapture.priority = UILayoutPriorityDefaultLow
			sealDetailsTableViewController?.dateToBottomCapture.priority = 999
		} else {
			sealDetailsTableViewController?.placeToBottomCapture.priority = 999
			sealDetailsTableViewController?.dateToBottomCapture.priority = UILayoutPriorityDefaultLow
		}
		guard let signature = tweetViewModel.extendedMedia?.last else {
			guard let image = tweetViewModel.signatureImage else { return }
			sealDetailsTableViewController?.mediasView.configureWith(image: image)
			return
		}
		sealDetailsTableViewController?.mediasView.configureWith(mediaItems: [signature])
	}
	
	func updateSealFields(_ seal: Seal?) {
		guard let requiredSeal = seal else {
			return
		}
		sealDetailsTableViewController?.sealDescriptionLabel.text = requiredSeal.sealDescription + "\n\(requiredSeal.infoUrl)"
	}
}
