//
//  UserListInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/11/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

protocol TwitterUserListRequest: JSONRequest, MapperParsing {
    
    associatedtype Model = EmbedUsers
}

class UserListInteractor: BaseInteractor {
    weak var presenter: UserListPresenter!
    var endpoint: Request.Users.UserList.Endpoint = .followers
    var userId: TwitterId!
    
    private var cursor: Int?
    
    func shouldInfiniteScroll() -> Bool {
        return cursor != nil && cursor != 0
    }
    
    func reloadUsers(completion: @escaping ResultClosure<[User]>) {
        cursor = nil
        loadUsers(endpoint: endpoint, cursor: nil, completion: completion)
    }

    func loadMoreUsers(completion: @escaping ResultClosure<[User]>) {
        guard let cursor = cursor else { return }
        loadUsers(endpoint: endpoint, cursor: cursor, completion: completion)
    }
    
    func loadUsers(endpoint: Request.Users.UserList.Endpoint, cursor: Int?, completion: @escaping ResultClosure<[User]>) {
        let request = Request.Users.UserList(userId: userId, endpoint: endpoint, cursor: cursor)
        networkService.fetch(resource: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.cursor = response.nextCursor
                completion(.success(response.users ?? []))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
	
	func actionForUser(userId: TwitterId,
                       actionType: Request.Users.UserSingleAction.ActionType,
                       completion: @escaping ResultClosure<User>) {
		let request = Request.Users.UserSingleAction(userId: userId, type: actionType)
		networkService.fetch(resource: request, completion: completion)
	}
    
    func unfollow(userId: TwitterId,
                  completion: @escaping ResultClosure<User>) {
        let request = Request.Users.UserSingleAction(userId: userId, type: .unFollow)
        networkService.fetch(resource: request, completion: completion)
    }

    func getUsersVerifiedStatus(forUsers users: [User], completion: @escaping ResultClosure<UsersVerifiedStatus>) {
        let uniqueUserIds = users.map({$0.id}) //Array(Set(tweets.map { $0.tweetInfo.user.id }))
        let request = Request.Users.VerifiedStatus(ids: uniqueUserIds)
        networkService.fetch(resource: request, completion: completion)
    }
}
