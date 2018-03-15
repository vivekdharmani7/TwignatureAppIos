//
//  HastagsSearchWireframe.swift
//  Twignature
//
//  Created by mac on 14.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

typealias HashtagsSearchConfiguration = (HashtagsSearchPresenter) -> Void

class HashtagsSearchWireframe {
    class func setup(_ viewController: HashtagsSearchViewController,
                     withCoordinator coordinator: TweetsForUserCoordinator,
                     configutation: HashtagsSearchConfiguration? = nil) {
        let interactor = HashtagsSearchInteractor()
        let presenter = HashtagsSearchPresenter(controller: viewController,
                interactor: interactor,
                coordinator: coordinator)
        viewController.presenter = presenter
        interactor.presenter = presenter
        configutation?(presenter)
    }
}
