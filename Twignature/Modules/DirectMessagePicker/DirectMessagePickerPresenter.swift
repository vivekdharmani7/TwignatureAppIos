//
//  DirectMessagePickerPresenter.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/2/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class DirectMessagePickerPresenter {
	
	var tweet: Tweet?
	
    //MARK: - Init
    required init(controller: DirectMessagePickerViewController,
                  interactor: DirectMessagePickerInteractor,
                  coordinator: DirectMessagePickerCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
	
	func viewIsReady() {
		searchAction(searchTerm: currentSearchTerm)
	}
	
    //MARK: - Private -
    fileprivate let coordinator: DirectMessagePickerCoordinator
    fileprivate unowned var controller: DirectMessagePickerViewController
    fileprivate var interactor: DirectMessagePickerInteractor
	
	func closeAction() {
		coordinator.dismiss()
	}
	
	func userSelectAction(user: User) {
		interactor.getRelationsFor(user: user) { [weak self] result in
			switch result {
			case .success(let relation):
				if relation.isFollowedBy {
					self?.openChatFor(user)
				} else {
					self?.showNotFollowerWarning(user)
				}
			case .failure(let error):
				print(error.localizedDescription)
				self?.showNotFollowerWarning(user)
			}
		}
	}
	
	private func openChatFor(_ user: User) {
		coordinator.dismiss()
		let conversation = Conversation(messages: [], user: user)
		var replyToUrl: String?
		if let tweet = tweet {
			replyToUrl = tweet.shareURL
		}
		coordinator.showChat(for: conversation, initialMessage: replyToUrl)
	}
	
	private func showNotFollowerWarning(_ user: User) {
		let alertController = UIAlertController(title: "Not followed",
		                                        message: R.string.twignatureError.notFollowedByYouWarning(),
		                                        preferredStyle: UIAlertControllerStyle.alert)
		let yesAction = UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
			self?.openChatFor(user)
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
		alertController.addAction(cancelAction)
        alertController.addAction(yesAction)
		controller.present(alertController, animated: true, completion: nil)
	}
	
	private var currentSearchTerm: String = "" {
		didSet {
			page = 0
		}
	}
	
	private var nextPage: Int = 0
	private var nextCursor: Int = -1
	private var page: Int = 0
	private var cursor: Int = -1

	func searchAction(searchTerm: String) {
		currentSearchTerm = searchTerm
		searchUsers(forNextPage: false)
	}
	
	private func searchUsers(forNextPage: Bool) {
		let curPage = forNextPage ? self.nextPage : self.page
		let curCursor = forNextPage ? self.nextCursor : self.cursor
		
		interactor.search(term: currentSearchTerm, page: page, cursor: cursor) { [weak self] result in
			self?.isRefreshing = false
			self?.controller.hideInprogress()

			switch result {
			case .success(let usersWithPaging):
				self?.usersDidFetch(usersWithPaging: usersWithPaging,
				                    curPage: curPage, curCursor: curCursor,
				                    forNextPage: forNextPage)
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}

	private func usersDidFetch(usersWithPaging:UsersWithPaging,
	                           curPage: Int,
	                           curCursor: Int,
	                           forNextPage: Bool) {
		let users = usersWithPaging.users
		nextCursor = usersWithPaging.nextСursor
		nextPage = usersWithPaging.nextPage
		page = curPage
		cursor = curCursor
		if forNextPage {
			updateWithUniqueUsers(usersToAdd: users)
		} else {
			controller.users = users
		}
	}
	
	private func updateWithUniqueUsers(usersToAdd : [User]) {
		guard !usersToAdd.isEmpty else {
			return
		}
		var users = controller.users
		guard !users.isEmpty else {
			controller.users = usersToAdd
			return
		}
		
		users.append(contentsOf: usersToAdd)
		let uniqueObjects = Set(users.map { $0 })
		users = uniqueObjects.map({ $0 }).sorted(by: { $0.0.name > $0.1.name })
		controller.users = users
	}
	
	private var isRefreshing = false
	
	func refreshAction() {
		guard !isRefreshing else { return }
		isRefreshing = true
		searchUsers(forNextPage: false)
	}
	
	func loadNextAction() {
		guard !isRefreshing else { return }
		isRefreshing = true
		searchUsers(forNextPage: true)
	}
}
