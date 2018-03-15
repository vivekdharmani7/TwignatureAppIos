//
//  SettingsPresenter.swift
//  Twignature
//
//  Created by mac on 12.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SettingsPresenter {
    
    //MARK: - Init
    required init(controller: SettingsViewController,
                  interactor: SettingsInteractor,
                  coordinator: SettingsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: SettingsCoordinator
    fileprivate unowned var controller: SettingsViewController
    fileprivate var interactor: SettingsInteractor
	fileprivate var viewModel: SettingsViewModel?
	
	func viewIsReady() {
		guard let user = Session.current?.user else { return }
		let viewModel = SettingsViewModel(withAccount: user)
		self.viewModel = viewModel
		controller.setupViewModel(viewModel)
		controller.showHUD()
		interactor.fetchCurrentUserInfo() { [weak self] (result) in
			switch result {
			case .success(let user):
                guard let strongsSelf = self else { return }
				let viewModel = SettingsViewModel(withAccount: user)
				strongsSelf.viewModel = viewModel
				strongsSelf.controller.setupViewModel(viewModel)
                strongsSelf.interactor.fetchAccountSettings({ [weak self] (result) in
                    switch result {
                    case .success(let settings):
                        self?.viewModel?.setShouldDisplaySensetiveContent(settings.displaySensitiveMedia)
                        self?.controller.setupViewModel(viewModel)
                        self?.controller.hideHUD()
                    case .failure(let error):
                        self?.controller.hideHUD()
                        self?.controller.showError(error)
                    }
                })
			case .failure(let error):
				self?.controller.hideHUD()
				self?.controller.showError(error)
			}
		}
	}
	
	func backButtonAction() {
		coordinator.dismiss()
	}
	
	func doneButtonAction() {
		controller.showHUD()
		interactor.updateUserWith(name: viewModel?.accoutSettings[.fullName] as? String,
		                          url: viewModel?.accoutSettings[.url] as? String,
		                          location: viewModel?.accoutSettings[.location] as? String,
		                          description: viewModel?.accoutSettings[.accountDescription] as? String,
                                  displaySensitiveContent: nil) { [weak self] (result) in
									switch result {
									case .success(let user):
										self?.controller.hideHUD()
										self?.controller.showAlert(with: "Settings updated successfully")
										Session.current?.updateSessionWithUser(user)
										break
									case .failure(let error):
										self?.controller.hideHUD()
										self?.controller.showError(error)
										break
									}
		}
	}
	
	func actionForSectionItemI(_ section: SettingsViewModelSection, item: Field) {
		switch section {
		case .account, .count: break
		case .safety:
			guard let safetyItem = item as? SettingsViewModelSafety else { return }
			switch safetyItem {
			case .muttedList:
				muttedListAction()
			case .blockedList:
				blockedListAction()
            case .twitterSettings:
                openTwitterSettings()
			case .count: break
			}
		case .about:
			guard let aboutItem = item as? SettingsViewModelAbout else { return }
			switch aboutItem {
			case .privacy:
				privacyAction()
			case .termsOfUse:
				termsOfUseAction()
			case .count: break
			}
//		case .contacts:
//			print("action for contacts")
		}
	}
	
	private func openTwitterSettings() {
		guard let url = URL(string: Links.twitterSafetySettings) else { return }
		interactor.openUrl(url)
	}
	
	func mailAction() {
		interactor.openUrl(URL(string: Links.supportMail)!)
	}
	
	//MARK: - PRIVATE
	
	private func muttedListAction() {
		coordinator.showMutedUsersList()
	}
	
	private func blockedListAction() {
		coordinator.showBlockedUsersList()
	}
    
   	private func privacyAction() {
        guard let url = URL(string: Links.privacy) else { return }
        interactor.openUrl(url)
	}
	
	private func termsOfUseAction() {
		guard let url = URL(string: Links.terms) else { return }
		interactor.openUrl(url)
	}
}
