//
//  LocationDisplayerPresenter.swift
//  Twignature
//
//  Created by mac on 29.09.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class LocationDisplayerPresenter {
	
	var location: Location?
	
    //MARK: - Init
    required init(controller: LocationDisplayerViewController,
                  interactor: LocationDisplayerInteractor,
                  coordinator: LocationDisplayerCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: LocationDisplayerCoordinator
    fileprivate unowned var controller: LocationDisplayerViewController
    fileprivate var interactor: LocationDisplayerInteractor
	
	func viewIsReady() {
		guard let location = self.location else {
			return
		}
		controller.setupLocation(location)
	}
	
	func backAction() {
		coordinator.dismiss()
	}
}
