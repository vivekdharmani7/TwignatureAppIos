//
//  RequestVerificationViewController.swift
//  Twignature
//
//  Created by mac on 01.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class RequestVerificationViewController: BaseViewController {
    //MARK: - Properties
    var presenter:  RequestVerificationPresenter!
    
	@IBOutlet weak var nameTextField: JVFloatLabeledTextField!
	@IBOutlet weak var emailTextField: JVFloatLabeledTextField!
	@IBOutlet weak var phoneTextField: JVFloatLabeledTextField!
	@IBOutlet weak var reasonTextView: JVFloatLabeledTextView!
	//MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		presenter.viewIsReady()
        configureInterface()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.isNavigationBarHidden = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
//		self.navigationController?.isNavigationBarHidden = false
	}
	
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
    }
    
    private func localizeViews() {
    }
	
	//MARK: - IBActions
	
	@IBAction private func backButtonDidTap(_ sender: Any) {
		presenter.backAction()
	}
	
	@IBAction private func sendButtonDidTap() {
		presenter.submitAction()
	}
	
}
