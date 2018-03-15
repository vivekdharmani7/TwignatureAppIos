//
//  DirectMessagePickerInteractor.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/2/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

struct UsersWithPaging {
	let users: [User]
	let nextPage: Int
	let nextСursor: Int
}

class DirectMessagePickerInteractor: BaseInteractor {
    weak var presenter: DirectMessagePickerPresenter!
	
	func getRelationsFor(user: User, completion: @escaping ResultClosure<RelationshipWithUser>) {
		let request = Request.Users.FriendshipsLookup(userId: user.id, screenName: user.screenName)
		networkService.fetchArray(resource: request) { result in
			switch result {
			case .success(let relations):
				guard let relation = relations.first else {
					completion(Result.failure(TwignatureError.unexpectedResult))
					return
				}
				completion(Result.success(relation))
			case .failure(let error):
				completion(Result.failure(error))
			}
		}
	}
	
	func search(term: String, page: Int, cursor: Int, completion: @escaping ResultClosure<UsersWithPaging>) {
		if term.isEmpty {
			fetchFollowers(page: page, cursor: cursor, completion: completion)
		} else {
			searchUsers(term: term, page: page, cursor: cursor, completion: completion)
		}
	}
	
	private func fetchFollowers(page: Int, cursor: Int, completion: @escaping ResultClosure<UsersWithPaging>) {
		let user = Session.current?.user
        let request = Request.Users.UserList(userId: user?.id, endpoint: .followers, count: 20, skipStatus: true, cursor: cursor)
		networkService.cancelRequest()
		networkService.fetch(resource: request) { result in
			switch result {
			case .success(let embedUsers):
				let users = embedUsers.users ?? []
				let usersWithPaging = UsersWithPaging(users: users, nextPage: page + 1, nextСursor: embedUsers.nextCursor ?? -1)
				completion(Result<UsersWithPaging>.success(usersWithPaging))
			case .failure(let error):
				completion(Result<UsersWithPaging>.failure(error))
			}
		}
	}
	
	private func searchUsers(term: String, page: Int, cursor: Int, completion: @escaping ResultClosure<UsersWithPaging>) {
		let request = Request.Users.Search(query: term, page: 0)
		networkService.cancelRequest()
		networkService.fetchArray(resource: request) { result in
			switch result {
			case .success(let users):
				let usersWithPaging = UsersWithPaging(users: users, nextPage: page + 1, nextСursor: cursor)
				completion(Result<UsersWithPaging>.success(usersWithPaging))
			case .failure(let error):
				completion(Result<UsersWithPaging>.failure(error))
			}
		}
	}

}
