//
//  User.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/8/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Networking

extension Request {
    enum Users {
		
		struct Update: JSONRequest, MapperParsing {
			
			typealias Model = User
			
			var name: String?
			var url: String?
			var location: String?
			var userDescription: String?
			
			var method: Method = .post
			var path: String = "account/update_profile.json"
			var parameters: [String : Any]? {
				var p: [String : Any] = [:]
				if let name = name { p["name"] = name }
				if let url = url { p["url"] = url.description }
				if let userDescription = userDescription { p["description"] = userDescription }
				if let location = location { p["location"] = location }
				return p
			}
			
			init(name: String?,
			     url: String?,
			     location: String?,
			     userDescription: String?) {
				self.name = name
				self.url = url
				self.location = location
				self.userDescription = userDescription
			}
		}
		
        struct Details: JSONRequest, MapperParsing {
            
            typealias Model = User
            
            private let userId: String
            private let screenName: String
                        
            let path: String = "users/show.json"
            var parameters: [String : Any]? {
                return [
                    "user_id" : userId,
                    "screen_name" : screenName,
                    "include_entities" : "\(false)"
                ]
            }
            
            init(userId: String, screenName: String) {
                self.userId = userId
                self.screenName = screenName
            }
        }
        
        struct RequestVerification: JSONRequest, MapperParsing {
            var path: String = "authorized/verification_requests"
            
            typealias Model = OptionalModel
            var host: RequestDestionation = .server
            
            var message: String
            var phone: String
            var email: String
            var name: String
            
            var method: Method = .post
            var parameterEncoding: Networking.ParameterType = Networking.ParameterType.json
            var parameters: [String : Any]? {
                return ["verification_request": ["message": message,
                                                 "phone": phone,
                                                 "email": email,
                                                 "name": name]]
            }
            
            init(withMessage message: String,
                 phone: String,
                 email: String,
                 name: String) {
                self.message = message
                self.phone = phone
                self.email = email
                self.name = name
            }
            
        }
        
        struct Search: JSONRequest, MapperParsing {
            
            typealias Model = User
            
            private let query: String
            private let page: Int
            
            let path: String = "users/search.json"
            var parameters: [String : Any]? {
                return [
                    "q" : query,
                    "page" : "\(page)"
                ]
            }
            
            init(query: String, page: Int) {
                self.query = query
                self.page = page
            }
            
        }
		
		struct UserList: JSONRequest, MapperParsing {
			
			typealias Model = EmbedUsers
			
            enum Endpoint: String {
                case followers = "followers/list.json"
                case friends = "friends/list.json"
				case mutes = "mutes/users/list.json"
				case blocks = "blocks/list.json"
            }
            
			let host: RequestDestionation = .twitter			
			private(set) var path: String
            
			private(set) var parameters: [String : Any]?
			
            init(userId: TwitterId? = nil, endpoint: Endpoint, screenName: String? = nil,
                 count: Int? = nil, skipStatus: Bool? = nil, cursor: Int? = nil) {
				var p = [String : Any]()
				p["user_id"] = userId
				p["screen_name"] = screenName
				p["count"] = count?.description
				p["skip_status"] = skipStatus?.description
				p["cursor"] = cursor?.description
				self.parameters = p
                self.path = endpoint.rawValue
			}
		}
		
		struct FriendshipsLookup: JSONRequest, MapperParsing {
			
			typealias Model = RelationshipWithUser
			
			let host: RequestDestionation = .twitter
			let path: String = "friendships/lookup.json"
			private(set) var parameters: [String : Any]?
			
			init(userId: TwitterId? = nil, screenName: String? = nil) {
				var parameters = [String : Any]()
				parameters["user_id"] = userId
				parameters["screen_name"] = screenName
				self.parameters = parameters
			}
		}
		
		/*
		@desc request to complete authorization on backend 
		after twitter OAuth
		*/
		struct Auth: JSONRequest, MapperParsing {
			// stored values
			private let userId: String
			private let twitterSecret: String
            private let pushToken: String?
			// response type
			typealias Model = TempUser
			// request configuration
			let path: String = "authorization"
			var method: Method = .post
			var host: RequestDestionation = .server
			var parameters: [String : Any]? {
				let nestedObject = ["id": userId,
				                    "secret": twitterSecret,
                                    "push_token": pushToken]
				return ["authorized": nestedObject]
			}
			//Initiation
			init(userId: String,
			     twitterSecret: String,
                 pushToken: String?) {
				self.userId = userId
				self.twitterSecret = twitterSecret
                self.pushToken = pushToken
			}
		}
        
        struct Logout: JSONRequest, MapperParsing {
            typealias Model = OptionalModel
            
            var path: String = "authorized/authorization"
            var method: Method = .delete
            var host: RequestDestionation = .server
        }
		
		/*
		@desc get current user info
		*/
		struct Current: JSONRequest, MapperParsing {
			
			typealias Model = TempUser
			
			let path: String = "authorized/user"
			var method: Method = .get
			var host: RequestDestionation = .server
		}
		
		struct UserSingleAction: JSONRequest, MapperParsing {
			typealias Model = User
			
			let method: Method = .post
			
			enum ActionType {
				case follow(enableNotifications: Bool?)
				case unFollow
				case mute
				case unmute
				case block
				case unblock
				case reportSpam(performBlock: Bool?)
			}
			
			private(set) var path: String = ""
			private(set) var parameters: [String : Any]?
			
			init(userId: TwitterId, type: ActionType) {
				var p = [String : Any]()
				p["user_id"] = userId
				switch type {
				case .follow(let enableNotifications):
					p["follow"] = enableNotifications?.description
					path = "friendships/create.json"
				case .unFollow:
					path = "friendships/destroy.json"
				case .mute:
					path = "mutes/users/create.json"
				case .block:
					path = "blocks/create.json"
				case .unmute:
					path = "mutes/users/destroy.json"
				case .unblock:
					path = "blocks/destroy.json"
				case .reportSpam(let performBlock):
					p["perform_block"] = performBlock?.description
					path = "users/report_spam.json"
				}
				
				parameters = p
			}
			
		}
        
        struct UserSettings: JSONRequest, MapperParsing {
            typealias Model = UserSetting
            
            let path: String = "account/settings.json"
            let method: Method = .get
        }
		
        struct UpdateUserSettings: JSONRequest, MapperParsing {
            typealias Model = OptionalModel
            
            let path: String = "account/settings.json"
            let method: Method = .post
            var shoudDisplaySensetive: Bool
            
            var parameters: [String : Any]? {
                return ["display_sensitive_media": shoudDisplaySensetive.description]
            }
            
            init(withShoudDisplaySensetive sensetive: Bool) {
                self.shoudDisplaySensetive = sensetive
            }
        }
        
		struct VerifiedStatus: JSONRequest, MapperParsing {
			typealias Model = UsersVerifiedStatus
			
			let host: RequestDestionation = .server
			let path: String
			let method: Method = .get
			let parameterEncoding: Networking.ParameterType = .none
			
			init(ids: [TweetID]) {
				path = "authorized/users?ids[]=" + ids.joined(separator: "&ids[]=")
			}
		}
    }
}
