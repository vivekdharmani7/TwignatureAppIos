//
//  SignInViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import BEMCheckBox
import TTTAttributedLabel

class SignInViewController: UIViewController {
    
	@IBOutlet weak var checkBoxContainer: UIView!
	@IBOutlet fileprivate weak var detailLabel: UILabel!
    @IBOutlet fileprivate weak var loginButton: UIButton!
	private var checkbox: BEMCheckBox?
    //MARK: - Properties
    var presenter:  SignInPresenter!
    
    //MARK: - Life cycle
    
	@IBOutlet weak var agreeLabel: TTTAttributedLabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        presenter.viewIsReady()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
		
		let checkbox = BEMCheckBox(frame: CGRect.zero)
		checkbox.boxType = .square
		checkbox.onCheckColor = UIColor.white
		checkbox.onFillColor = #colorLiteral(red: 0, green: 0.8080386519, blue: 1, alpha: 1)
		checkbox.offFillColor = #colorLiteral(red: 0, green: 0.8080386519, blue: 1, alpha: 1)
		checkbox.onTintColor = UIColor.clear
		checkbox.tintColor = UIColor.clear
		checkbox.delegate = self
		checkBoxContainer.addSubview(checkbox)
		checkbox.pinToSuperview()
		self.checkbox = checkbox
		
		agreeLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
		let termsAndConditions = R.string.authorization.termsAndConditions()
		let iAgreeToThe = R.string.authorization.iAgreeToThe()
		agreeLabel.text = "\(iAgreeToThe) \(termsAndConditions)."
		agreeLabel.delegate = self
		var linkAttributes = agreeLabel.linkAttributes ?? [AnyHashable: Any]()
		linkAttributes[NSForegroundColorAttributeName] = agreeLabel.textColor
		agreeLabel.linkAttributes = linkAttributes
		var activeLinkAttributes = agreeLabel.activeLinkAttributes ?? [AnyHashable: Any]()
		activeLinkAttributes[NSForegroundColorAttributeName] = UIColor.white
		agreeLabel.activeLinkAttributes = activeLinkAttributes
		
		let range = (agreeLabel.text?.range(for: termsAndConditions))!
		let url = URL(string: "http://")!
		agreeLabel.addLink(to: url, with: range)
		
		loginButton.isEnabled = false
    }
    
    private func localizeViews() {
        detailLabel.text = R.string.authorization.appDescription()
        loginButton.setTitle(R.string.authorization.loginTwitter(), for: .normal)
    }
    
    //MARK: - IBActions
    @IBAction private func didPressLogin(_ sender: Any) {
        presenter.handleLogin()
    }
}

extension SignInViewController: TTTAttributedLabelDelegate {
	func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
		presenter.termsOfUseAction()
	}
}

extension SignInViewController: BEMCheckBoxDelegate {
	func didTap(_ checkBox: BEMCheckBox) {
		loginButton.isEnabled = checkBox.on
	}
}
