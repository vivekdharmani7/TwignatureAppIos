//
//  ConversationWireframe.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/29/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias ConversationConfiguration = (ConversationPresenter) -> Void

class ConversationWireframe {
    class func setup(_ viewController: ConversationViewController,
                     withCoordinator coordinator: ConversationCoordinator,
                     configuration: ConversationConfiguration? = nil) {
        let interactor = ConversationInteractor()
        let presenter = ConversationPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configuration?(presenter)
    }
}
