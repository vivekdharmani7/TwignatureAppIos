//
//  MediaTweetsWireframe.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/9/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias MediaTweetsConfiguration = (MediaTweetsPresenter) -> Void

class MediaTweetsWireframe {
    class func setup(_ viewController: MediaTweetsViewController,
                     withCoordinator coordinator: MediaTweetsCoordinator,
                     configutation: MediaTweetsConfiguration? = nil) {
        let interactor = MediaTweetsInteractor()
        let presenter = MediaTweetsPresenter(controller: viewController,
                                                          interactor: interactor,
                                                          coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
