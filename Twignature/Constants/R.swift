//
//  R.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import UIKit

// swiftlint:disable type_name

fileprivate enum FileName {
    static let launch = "LaunchScreen"
    static let main = "Main"
    static let authorization = "Authorization"
    static let profile = "Profile"
    static let feed = "Feed"
    static let tweets = "Tweets"
    static let chats = "Chats"
	static let twignatureError = "TwignatureError"
	static let tweetDetails = "TweetDetails"
	static let onBoarding = "OnBoarding"
}

enum R {
    enum Storyboard {
        static fileprivate let launch = UIStoryboard(name: FileName.launch, bundle: nil)
        static fileprivate let authorization = UIStoryboard(name: FileName.authorization, bundle: nil)
        static fileprivate let main = UIStoryboard(name: FileName.main, bundle: nil)
        static fileprivate let profile = UIStoryboard(name: FileName.profile, bundle: nil)
        static fileprivate let feed = UIStoryboard(name: FileName.feed, bundle: nil)
        static fileprivate let tweets = UIStoryboard(name: FileName.tweets, bundle: nil)
        static fileprivate let chats = UIStoryboard(name: FileName.chats, bundle: nil)
		static fileprivate let tweetDetails = UIStoryboard(name: FileName.tweetDetails, bundle: nil)
		static fileprivate let onBoarding = UIStoryboard(name: FileName.onBoarding, bundle: nil)

        enum Splash {
            static var splashViewController: UIViewController {
                return Storyboard.launch.instantiateViewController(withIdentifier: "Splash")
            }
        }
        enum Authorization {
            static var signInViewController: SignInViewController {
                return SignInViewController.instantiate(from: Storyboard.authorization)
            }
        }
        
        enum Main {
            static var topBarViewController: TopBarController {
                return TopBarController.instantiate(from: Storyboard.main)
            }
        }
        
        enum Profile {
            static var profileViewController: ProfileViewController {
                return ProfileViewController.instantiate(from: Storyboard.profile)
            }
        }

		enum OnBoarding {
			static var onBoardingTutorialViewController: OnBoardingTutorialViewController {
				return OnBoardingTutorialViewController.instantiate(from: Storyboard.onBoarding)
			}
			static var onBoardingAcceptViewController: OnBoardingAcceptViewController {
				return OnBoardingAcceptViewController.instantiate(from: Storyboard.onBoarding)
			}
		}

        enum Feed {
            static var feedViewController: FeedViewController {
                return FeedViewController.instantiate(from: Storyboard.feed)
            }
        }

        enum Tweets {
            static var createTweetViewController: CreateTweetViewController {
                return CreateTweetViewController.instantiate(from: Storyboard.tweets)
            }
        }

		enum TweetDetails {
			static var tweetDetailsViewController: TweetDetailsViewController {
				return TweetDetailsViewController.instantiate(from: Storyboard.tweetDetails)
			}
		}

        enum Chats {
            static var chatController: ChatsViewController {
                return ChatsViewController.instantiate(from: Storyboard.chats)
            }
        }
    }

    enum Cell {
        static let tweet = TweetCell.self
        static let floatingTitleCell = FloatingTitledCell.self
        static let media = MediaCell.self
        static let mediaItem = MediaItemCell.self
        static let chat = ChatCell.self
		static let onBoardAcceptTableViewCell = OnBoardAcceptTableViewCell.self
		static let onBoardTextTableViewCell = OnBoardTextTableViewCell.self
		static let iconTopTableViewCell = IconTopTableViewCell.self
        static let user = UserCell.self
		static let comment = CommentCell.self
		static let moreReplies = MoreRepliesCell.self
    }
    
    enum String {
        enum Authorization {
            static let loginTwitter = "login.twitter".localized(file: FileName.authorization)
            static let appDescription = "app.description".localized(file: FileName.authorization)
        }
        
        enum Profile {
            static let following = "following".localized(file: FileName.profile)
            static let followers = "followers".localized(file: FileName.profile)
            static let mentions = "mentions".localized(file: FileName.profile)
            static let likes = "likes".localized(file: FileName.profile)
            static let tweets = "tweets".localized(file: FileName.profile)
            static let media = "media".localized(file: FileName.profile)
            static let viewAll = "viewAll".localized(file: FileName.profile)
        }

		enum TwignatureErrorTexts {
			static let twitterAccountNotFound = "twitterAccountNotFound".localized(file: FileName.twignatureError)
			static let unauthorized = "unauthorized".localized(file: FileName.twignatureError)
			static let accessDenied = "accessDenied".localized(file: FileName.twignatureError)
		}

		enum OnBoardingTexts {
			static let firstPageText = "firstOnBoardingText".localized(file: FileName.onBoarding)
			static let secondPageText = "secondOnBoardingText".localized(file: FileName.onBoarding)
			static let thirdPageText = "thirdOnBoardingText".localized(file: FileName.onBoarding)
			static let fourthPageText = "fourthOnBoardingText".localized(file: FileName.onBoarding)
		}
    }
}
