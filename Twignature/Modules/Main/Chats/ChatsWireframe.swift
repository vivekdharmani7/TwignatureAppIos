//
//  ChatsWireframe.swift
//  Twignature
//
//  Created by Anton Muratov on 9/14/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias ChatsConfiguration = (ChatsPresenter) -> Void

class ChatsWireframe {
    class func setup(_ viewController: ChatsViewController,
                     withCoordinator coordinator: ChatsCoordinator,
                     configutation: ChatsConfiguration? = nil) {
        let interactor = ChatsInteractor()
        let presenter = ChatsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
