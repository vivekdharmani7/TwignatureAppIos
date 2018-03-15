//
//  OnBoardingTutorialWireframe.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias OnBoardingTutorialConfiguration = (OnBoardingTutorialPresenter) -> Void

class OnBoardingTutorialWireframe {
    class func setup(_ viewController: OnBoardingTutorialViewController,
                     withCoordinator coordinator: OnBoardingTutorialCoordinator,
                     configutation: OnBoardingTutorialConfiguration? = nil) {
        let interactor = OnBoardingTutorialInteractor()
        let presenter = OnBoardingTutorialPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
