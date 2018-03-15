//
//  SideMenuViewController.swift
//  Twignature
//
//  Created by mac on 05.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SideMenuViewController: BaseViewController {
    //MARK: - Properties
    var presenter:  SideMenuPresenter!
	
	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var profileNickLabel: UILabel!
	@IBOutlet weak var profileFullNameLabel: UILabel!
	
	@IBOutlet weak var profileFollowersCountLabel: UILabel!
	@IBOutlet weak var profileFollowingCountLabel: UILabel!

	@IBOutlet weak var purchasePowerPenButton: UIButton!
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
    //MARK: - Life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.viewAppeared()
		print("viewDidAppear")
	}
	
	//MARK: - PUBLIC
	
	func updateUserProfileImage(_ imagePath: URL) {
		profileImageView.kf.setImage(with: imagePath)
	}
	
	func updateProfile(_ userName: String, _ fullName: String) {
		profileNickLabel.text = userName 
		profileFullNameLabel.text = fullName
	}
	
	func updateProfileFollowers(_ followers: Int, andFolloing following: Int) {
		profileFollowingCountLabel.text = "\(following)"
		profileFollowersCountLabel.text = "\(followers)"
	}

	func needToShowPurchasePowerPen(_ show: Bool) {
		purchasePowerPenButton.isHidden = !show
		purchasePowerPenButton.isUserInteractionEnabled = show
	}

    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
	
	//MARK: - Actions
	
	@IBAction func avatarDidTap(_ sender: Any) {
		presenter.profileAction()
	}
	
	@IBAction private func crossDidTap(_ sender: Any) {
		presenter.crossAction()
	}
	
	@IBAction private func profileDidTap(_ sender: Any) {
		presenter.profileAction()
	}
	
	@IBAction private func twignatureDidTap(_ sender: Any) {
		presenter.twignatureAction()
	}
	
	@IBAction private func settingsAndPrivacyDidTap(_ sender: Any) {
		presenter.settingsAndPrivacyAction()
	}
	
	@IBAction private func verificationRequestDidTap(_ sender: Any) {
		presenter.verificationRequestAction()
	}

	@IBAction private func purchaseSealDidTap(_ sender: Any) {
		presenter.purchaseSealAction()
	}

	@IBAction private func purchasePowerPenDidTap(_ sender: Any) {
		presenter.purchasePowerPenAction()
	}

	@IBAction private func logoutDidTap(_ sender: Any) {
		presenter.logoutAction()
	}

}
