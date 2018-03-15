//
//  HastagsSearchPresenter.swift
//  Twignature
//
//  Created by mac on 14.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class HashtagsSearchPresenter: TweetsForUserPresenter {
    
    //MARK: - Init
    required init(controller: HashtagsSearchViewController,
                  interactor: HashtagsSearchInteractor,
                  coordinator: TweetsForUserCoordinator) {
        super.init(controller: controller, interactor: interactor, coordinator: coordinator)
        guard let user = Session.current?.user else {
            fatalError("Session should be available")
        }
        self.user = user
    }

    required init(controller: TweetsForUserViewController,
                  interactor: TweetsForUserInteractor,
                  coordinator: TweetsForUserCoordinator) {
        fatalError("init(controller:interactor:coordinator:) has not been implemented")
    }

    //MARK: - Private -
    fileprivate var hashtagController: HashtagsSearchViewController? {
        return  self.controller as? HashtagsSearchViewController
    }
    fileprivate var hashtagInteractor: HashtagsSearchInteractor? {
        return self.interactor as? HashtagsSearchInteractor
    }
//    fileprivate var hashtag: String = ""


    func setHashtag(_ value: String) {
        hashtagInteractor?.hashtag = value
        hashtagController?.setupSearchText(value)
    }

    func handleSearchInput(query: String?) {
        if let query = query, !query.isEmpty {
//            if viewModel?.isSearchActive != true {
//                controller.updateView(isSearchEnabled: true)
//                viewModel?.isSearchActive = true
//            }
            let regularExpressionString = "^.*([[:alnum:]])+"
            do {
                let regex = try NSRegularExpression(pattern: regularExpressionString)
                let results = regex.matches(in: query,
                        range: NSRange(query.startIndex..., in: query))
                if results.isEmpty {
                    print("error")
                } else {
                    hashtagInteractor?.hashtag = query
                    super.refreshTweets()
                }
            } catch let error {
                print("invalid regex: \(error.localizedDescription)")
            }
        } else {
//            viewModel?.isSearchActive = false
//            controller.updateView(isSearchEnabled: false)
//            finishSearch()
        }
    }
}
