//
//  SealDetailsPresenter.swift
//  Twignature
//
//  Created by mac on 04.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class SealDetailsPresenter {
    
    //MARK: - Init
    required init(controller: SealDetailsViewController,
                  interactor: SealDetailsInteractor,
                  coordinator: SealDetailsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
	
	var sealDetailsViewModel: SealDetailsViewModel?
	
    //MARK: - Private -
    fileprivate let coordinator: SealDetailsCoordinator
    fileprivate unowned var controller: SealDetailsViewController
    fileprivate var interactor: SealDetailsInteractor
	
	func viewIsReady() {
		guard let sealDetailsViewModel = self.sealDetailsViewModel else {
			return
		}
		controller.updateWithModel(sealDetailsViewModel)
	}
	
	//MARK: - PUBLIC -
	func backButtonAction() {
		coordinator.dismiss()
	}
	
	func linkAction(_ url: URL) {
		interactor.openUrl(url)
	}
	
	func shareButtonAction() {
		guard let infoPath = sealDetailsViewModel?.signId, let infoUrl = URL(string: NetworkService.environment.linksUrl + infoPath)
			else { return }
		coordinator.showActivityController(forResource: infoUrl)
	}
}
