//
//  OnBoardingAcceptViewController.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class OnBoardingAcceptViewController: BaseViewController {
    //MARK: - Properties
	@IBOutlet private weak var descriptionTextView: UITextView!
    var presenter:  OnBoardingAcceptPresenter!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		descriptionTextView.contentOffset = CGPoint(x: 0, y: 0)
	}
	
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
	
	@IBAction private func acceptButtonPressed() {
		presenter.acceptViewAction()
	}
}
