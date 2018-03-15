//
//  DirectMessagePickerWireframe.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/2/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias DirectMessagePickerConfiguration = (DirectMessagePickerPresenter) -> Void

class DirectMessagePickerWireframe {
    class func setup(_ viewController: DirectMessagePickerViewController,
                     withCoordinator coordinator: DirectMessagePickerCoordinator,
                     configutation: DirectMessagePickerConfiguration? = nil) {
        let interactor = DirectMessagePickerInteractor()
        let presenter = DirectMessagePickerPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
