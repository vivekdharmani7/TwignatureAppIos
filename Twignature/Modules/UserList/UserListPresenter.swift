//
//  UserListPresenter.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class UserListPresenter {
    
	var textForNodata: String?
	
    //MARK: - Init
    required init(controller: UserListViewController,
                  interactor: UserListInteractor,
                  coordinator: UserListCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: UserListCoordinator
    fileprivate unowned var controller: UserListViewController
    fileprivate var interactor: UserListInteractor
    
    var user: User!
    var title: String!
	var userAction: Request.Users.UserSingleAction.ActionType!
	var actionMessage: String! = "Are you sure you want to unfollow this user?"
	
	/*
	if u send nil as actionMessage message will not be changed
	*/
	func configure(endpoint: Request.Users.UserList.Endpoint,
	               userActionType: Request.Users.UserSingleAction.ActionType = .unFollow,
	               hidesCellButton: Bool = true,
	               actionMessage: String? = nil,
	               sideButtonTitle: String? = nil) {
        interactor.endpoint = endpoint
        interactor.userId = user.id
        controller.hidesCellButton = hidesCellButton
		self.userAction = userActionType
		self.actionMessage = actionMessage ?? self.actionMessage
		guard let sideTitle = sideButtonTitle else {
			return
		}
		controller.cellRightSideButtonTitle = sideTitle
    }
    
    func viewIsReady() {
		controller.textForNodata = textForNodata
        controller.title = title
        controller.set(avatar: user.profileImageUrl)
        controller.showHUD()
        reloadUsers()
    }
    
    func handlePullToRefresh() {
        reloadUsers()
    }
    
    func handleScrollToBottom() {
        interactor.loadMoreUsers { [weak self] (result) in
            self?.controller.endInfiniteScroll()
            switch result {
            case .success(let users):
                var usersViewModel: [UserListViewController.UserViewModel] = users.map { user in
                    let userId = user.id
                    let username = user.screenName
                    return UserListViewController.UserViewModel(user: user, selectionClosure: {
                        self?.coordinator.showUserProfile(userId: userId, userScreenName: username)
                    }, buttonCallback: {
                        self?.userAction(id: userId)
                    })
                }
                self?.controller.append(users: usersViewModel)
                self?.updateUsersVerifiedStatus(users)
            case .failure(let error):
                self?.controller.showError(error)
            }
        }
    }

    func updateUsersVerifiedStatus(_ users: [User]) {
        interactor.getUsersVerifiedStatus(forUsers: users) { [weak self] result in
            switch result {
                case .success(let status):
                    guard var usersViewModel = self?.controller.users else {
                        return
                    }
                    let statuses: [Int64: UsersVerifiedStatusItem] = status.users.reduce([Int64: UsersVerifiedStatusItem]())  { (dict, person) -> [Int64: UsersVerifiedStatusItem] in
                        var dict = dict
                        dict[person.id] = person
                        return dict
                    }
                    let newViewModels: [UserListViewController.UserViewModel] = usersViewModel.map { viewModel -> UserListViewController.UserViewModel in
                        var newViewModel: UserListViewController.UserViewModel = viewModel
                        newViewModel.isVerified = statuses[newViewModel.id.numId ?? -1]?.verified ?? newViewModel.isVerified
                        return newViewModel
                     }
                    self?.controller.reload(users: newViewModels)
                case .failure(let error):
                    break
            }
         }
    }
    
    func shouldInfiniteScroll() -> Bool {
        return interactor.shouldInfiniteScroll()
    }
    
    func handleBack() {
        coordinator.back()
    }
    
    // MARK: - Private
	
	private func userAction(id: TwitterId) {
		let alert = UIAlertController.alert(title: self.actionMessage)
			.action(title: R.string.common.no(), style: .cancel)
			.action(title: R.string.common.yes()) { [unowned self] _ in
				self.controller.showHUD()
				self.interactor.actionForUser(userId: id,
				                              actionType: self.userAction,
				                              completion: { [weak self] result in
												self?.controller.hideHUD()
												switch result {
												case .success:
													self?.controller.removeUser(id: id)
												case .failure(let error):
													self?.controller.showError(error)
												}
				})
		}
		controller.show(alert: alert)
	}
    
    private func reloadUsers() {
        interactor.reloadUsers { [weak self] (result) in
            self?.controller.hideHUD()
            switch result {
            case .success(let users):
                self?.controller.reload(users: users.map { user in
                    let userId = user.id
                    let username = user.screenName
                    return UserListViewController.UserViewModel(user: user, selectionClosure: {
                        self?.coordinator.showUserProfile(userId: userId, userScreenName: username)
                    }, buttonCallback: {
                        self?.userAction(id: userId)
                    })
                })
                self?.updateUsersVerifiedStatus(users)
            case .failure(let error):
                self?.controller.showError(error)
            }
        }
    }
}
