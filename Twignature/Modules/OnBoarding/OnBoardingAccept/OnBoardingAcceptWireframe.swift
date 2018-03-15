//
//  OnBoardingAcceptWireframe.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias OnBoardingAcceptConfiguration = (OnBoardingAcceptPresenter) -> Void

class OnBoardingAcceptWireframe {
    class func setup(_ viewController: OnBoardingAcceptViewController,
                     withCoordinator coordinator: OnBoardingAcceptCoordinator,
                     configutation: OnBoardingAcceptConfiguration? = nil) {
        let interactor = OnBoardingAcceptInteractor()
        let presenter = OnBoardingAcceptPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
