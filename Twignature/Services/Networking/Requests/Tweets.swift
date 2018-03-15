//
//  Tweets.swift
//  Twignature
//
//  Created by Anton Muratov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Networking

extension Request {
    
    enum Tweets {
       struct Feed: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
        
            var path: String = "statuses/home_timeline.json"
			let lastId: String?
			
			var parameters: [String : Any]? {
				var parameters: [String : Any] = ["include_entities" : true.description ]
				parameters["tweet_mode"] = "extended"
				guard let lastId = self.lastId else {
					return parameters
				}
				parameters["max_id"] = lastId
				return parameters
			}
			
			init(_ lastId: String? = nil) {
				self.lastId = lastId
			}
        }
		
		struct FeedTNAPI: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			let path: String = "authorized/posts"
			let host = RequestDestionation.server
			
			var parameters: [String : Any]?
			
			init(lastId: TwitterId? = nil, count: Int? = nil, maxIdTwignature: Bool? = nil) {
				parameters = [String : Any]()
				parameters?["max_id"] = lastId
				parameters?["count"] = count?.description
				parameters?["max_id_twignature"] = maxIdTwignature?.description
			}
		}
		
		struct Timeline: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			private let userId: String
			
			let path: String = "statuses/user_timeline.json"
			var parameters: [String : Any]?
			
			init(userId: TwitterId, lastId: TwitterId? = nil, count: Int? = nil) {
				self.userId = userId
				parameters = [
					"user_id" : userId
				]
				parameters?["max_id"] = lastId
				parameters?["count"] = count?.description
				parameters?["tweet_mode"] = "extended"
			}
		}
		
		struct Retweet: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			var tweetId: String!
			
			var path: String = "statuses/retweet.json"
			var method: Method = .post
			var parameters: [String : Any]? {
				return ["id" : tweetId]
			}
			
			init(tweetId: String) {
				self.tweetId = tweetId
			}
		}
		
        struct Like: JSONRequest, MapperParsing, TweetContained {
            typealias Model = Tweet
            
            var tweetId: String!
            
            var method: Method = .post
            var path: String = "favorites/create.json"
            var parameters: [String : Any]? {
                return ["id" : tweetId]
            }
        }
        
        struct Unlike: JSONRequest, MapperParsing, TweetContained {
            typealias Model = Tweet
            
            var tweetId: String!
            
            var method: Method = .post
            var path: String = "favorites/destroy.json"
            var parameters: [String : Any]? {
                return ["id" : tweetId]
            }
        }
        
        struct Unretweet: JSONRequest, MapperParsing, TweetContained {
            typealias Model = Tweet
            
            var tweetId: String!
            
            var method: Method = .post
            var path: String {
                return "statuses/destroy/\(tweetId).json"
            }
        }

		struct Destroy: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			let method: Method = .post
			let path: String = "statuses/destroy.json"
			var parameters: [String : Any]?
			
			init(tweetId: TwitterId) {
				parameters =  ["id" : tweetId]
			}
		}
		
		struct CreateTweetRef: JSONRequest, MapperParsing {
			typealias Model = Identifier
			
			var path: String = "authorized/tweet_refs"
			var method: Method = .post
			var host: RequestDestionation = .server
			
			init() {}
		}
		
        struct Create: JSONRequest, MapperParsing, TweetContained {
            typealias Model = Tweet
            
            private let text: String
            private let location: Location?
			private let media: [TwitterMedia]?
			private let mediaIds: String?
			private let attachedTweet: Tweet?
			private let attachedTweetRole: AttachmentTweetRole?
			private let twitterReference: String?
            
            let path: String = "statuses/update.json"
            let method: Method = .post
            
            var parameters: [String : Any]? {
				var text = self.text
				if let twitterReference = self.twitterReference {
					text = "\(text) \(NetworkService.environment.linksUrl)\(twitterReference)"
				}
				var parameters: [String : Any] = ["status" : text]
				if let mediaIds = self.mediaIds, !mediaIds.isEmpty {
					parameters["media_ids"] = mediaIds
				}
				if let location = self.location {
					parameters["lat"] = "\(location.latitude)"
					parameters["long"] = "\(location.longitude)"
				}
				//attached tweet configuration
				if let attachedTweetRole = self.attachedTweetRole,
					let attachedTweet = self.attachedTweet {
					switch attachedTweetRole {
					case .reply:
						parameters["in_reply_to_status_id"] = attachedTweet.id
						parameters["status"] = "@\(attachedTweet.tweetInfo.user.screenName) \(text)"
					case .retweet:
						parameters["status"] = "\(attachedTweet.shareURL) \(text)"
					}
				}
                return parameters
            }
            
			init(text: String,
			     location: Location? = nil,
			     media: [TwitterMedia]? = nil,
			     twitterReference: String? = nil,
			     attachedTweet: Tweet? = nil,
			     attachedTweetRole: AttachmentTweetRole? = nil) {
                self.text = text
                self.location = location
				self.media = media
				self.attachedTweet = attachedTweet
				self.attachedTweetRole = attachedTweetRole
				let mediaIds = media?.map({ item -> String in
					item.mediaIdString
				})
				self.mediaIds = mediaIds?.joined(separator: ",")
				self.twitterReference = twitterReference
            }
        }
		
		struct CreateOnTwignature: JSONRequest, MapperParsing {
			typealias Model = OptionalModel
			
			let host: RequestDestionation = RequestDestionation.server
			let path: String = "authorized/posts"
			let method: Method = .post
			
			var tweetId: String!
			var tweetRef: String!
			
			var parameters: [String : Any]? {
				return ["post":
							["id" : tweetId,
							 "with_seal": true.description
							],
				        "tweet_ref_id": tweetRef
						]
			}
			
			init(_ tweetId: String, tweetRef: String) {
				self.tweetId = tweetId
				self.tweetRef = tweetRef
			}
		}
		
		struct UploadMedia: JSONRequest, MapperParsing {
			typealias Model = TwitterMedia
			
			private let image: UIImage
			
			var host: RequestDestionation = RequestDestionation.twitterUpload
			let path: String = "media/upload.json"
			let method: Method = .post
			let compression: CGFloat
			
			var parameters: [String : Any]? {
				let data = UIImageJPEGRepresentation(image, compression)
				guard let dataString = data?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
					return [:]
				}
				return [
					"media" : dataString
				]
			}
			
			init(image: UIImage, compression: CGFloat = 0.8) {
				self.image = image
				self.compression = compression
			}
		}
		
		struct SealsForTweets: JSONRequest, MapperParsing {
			typealias Model = Post
			
			var host: RequestDestionation = .server
			var path: String
			var method: Method = .get
			var parameterEncoding: Networking.ParameterType = .none
			
			init(ids: [TweetID]) {
				self.path = "posts?ids[]=" + ids.joined(separator: "&ids[]=")
			}
		}
		
		struct Mentions: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			let count: Int?
			let sinceId: String?
			let maxId: String?
			
			var path: String { return "statuses/mentions_timeline.json" }
			
			var parameters: [String : Any]? {
				var p = [ String: Any ] ()
				if let count = count { p["count"] = String(count) }
				if let sinceId = sinceId { p["since_id"] = sinceId }
				if let maxId = maxId { p["max_id"] = maxId }
				p["include_entities"] = "true"
				return p
			}
		}
		
		struct Retweets: JSONRequest, MapperParsing, TweetContained {
			typealias Model = Tweet
            
			let count: Int?
			let sinceId: String?
			let maxId: String?
			
			var path: String { return "statuses/retweets_of_me.json" }
			
			var parameters: [String : Any]? {
				var p = [ String: Any ] ()
				if let count = count { p["count"] = String(count) }
				if let sinceId = sinceId { p["since_id"] = sinceId }
				if let maxId = maxId { p["max_id"] = maxId }
				p["include_entities"] = "true"
				p["tweet_mode"] = "extended"
				return p
			}
		}
        
        struct Favorites: JSONRequest, MapperParsing, TweetContained {
            typealias Model = Tweet
            
            let path = "favorites/list.json"
            var parameters: [String : Any]?
            
            init(userId: TwitterId, lastId: TwitterId?) {
                parameters = [
                    "user_id" : userId
                ]
				parameters?["tweet_mode"] = "extended"
                parameters?["max_id"] = lastId
            }
        }
    }
}
