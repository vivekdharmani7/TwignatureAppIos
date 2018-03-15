//
//  AppFlow.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

fileprivate let kAppWasLaunched = "App was launched"

class AppFlow {

    private let window: UIWindow
	var router: BaseRouter!
	
    var rootViewController: UIViewController {
	   get {
            return window.rootViewController!
        }
        set {
            window.rootViewController = newValue
			router = BaseRouter(initialController: newValue)
        }
    }
    
    init(window: UIWindow) {
        self.window = window
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logout),
                                               name: NSNotification.Name(rawValue: NotificationIdentifier.SessionExpired),
                                               object: nil)
    }
    
    var appWasLaunched: Bool {
        get {
            return UserDefaults.standard.bool(forKey: kAppWasLaunched)
        } set {
            UserDefaults.standard.set(newValue, forKey: kAppWasLaunched)
        }
    }
    
    // MARK: - Public
    
    func startAppFlow() {
        if !appWasLaunched {
            appWasLaunched = true
            try? Session.logout()
        }
        if Session.isAuthorized {
            showSplash()
            Session.restore { [unowned self] result in
                switch result {
                case .success:
					Session.current?.updateSessionSensetive()
					guard UserDefaults.standard.bool(forKey: Key.onBoardingPressented) else {
						self.startOnBoardingFlow()
						return
					}
                    self.startMainFlow()
                case .failure(let error):
                    self.logout()
                    self.rootViewController.showError(error)
                }
            }
        } else {
            startAuthorizationFlow()
        }
    }
    
    func startMainFlow() {
		let navVC = mainFlowController()
        changeVC(with: navVC)
    }
	
	func mainFlowController() -> UIViewController {
		guard Session.current?.user != nil  else { fatalError("User not found") }
		guard let topBarVC = R.storyboard.main.topBarController(),
			let sidePanel = R.storyboard.main.sideMenuViewController() else {
				fatalError("screens not found")
		}
		//configure side panel
		SideMenuManager.menuLeftNavigationController?.setViewControllers([], animated: false)
		let router = BaseRouter(initialController: topBarVC)
		let mainFlowCoordinator = MainFlow(router: router, self)
		SideMenuWireframe.setup(sidePanel,
		                        withCoordinator: mainFlowCoordinator) { _ in
		}
		let sidePanelNavigation = UISideMenuNavigationController(rootViewController: sidePanel)
		if let transitionManager = sidePanelNavigation.transitioningDelegate as? SideMenuTransition {
			NotificationCenter.default.removeObserver(transitionManager,
			                                          name: NSNotification.Name.UIApplicationWillChangeStatusBarFrame,
			                                          object: nil)
		}
		sidePanelNavigation.leftSide = true
		sidePanelNavigation.isNavigationBarHidden = true
		let appWindowRect = UIApplication.shared.keyWindow?.bounds ?? UIWindow().bounds
		sidePanelNavigation.menuWidth = max(round(min((appWindowRect.width), (appWindowRect.height)) * 0.9), 240)
		//configure main top bar
		topBarVC.configure(topBarItems: topBarItems)
		let navVC = BaseNavigationController(rootViewController: topBarVC)
		navVC.view.backgroundColor = UIColor.white
		SideMenuManager.menuLeftNavigationController = sidePanelNavigation
        SideMenuManager.menuRightNavigationController = nil
		return navVC
	}
    
    func startAuthorizationFlow() {
		guard let vc = R.storyboard.authorization.signInViewController() else {
			return
		}
        SignInWireframe.setup(vc, withCoordinator: AuthorizationFlow(appFlow: self))
        changeVC(with: vc)
    }
	
	func startOnBoardingFlow() {
		let onBoardingFlow = OnBoardingFlow(appFlow: self)
		guard let initialController = try? onBoardingFlow.initialOnBoarding() else {
			return
		}
		changeVC(with: initialController)
	}
    
    // MARK: - Private
    
    private func showSplash() {
		guard let vc = R.storyboard.launchScreen().instantiateInitialViewController() else {
			return
		}
        changeVC(with: vc)
    }
    
    @objc
    func logout() {
		UserDefaults.standard.set(false, forKey: Key.onBoardingPressented)
        do {
            try Session.logout()
            startAuthorizationFlow()
        } catch {
            fatalError("Could not remove current session")
        }
    }
    
    //MARK: - Utils
    private func changeVC(with vc: UIViewController) {
        guard window.rootViewController != nil else {
            window.rootViewController = vc
            return
        }
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        transition.duration = 0.5
        window.layer.add(transition, forKey: kCATransition)
        window.rootViewController = vc
    }
    
    private var topBarItems: [TopBarItem] {
		guard let feedVC = R.storyboard.feed.feedViewController() else {
			return []
		}
        let router = BaseRouter(initialController: feedVC)
        let mainFlowCoordinator = MainFlow(router: router, self)
        FeedWireframe.setup(feedVC, withCoordinator: mainFlowCoordinator)
        feedVC.index = 0
        
        let chatsVC = R.storyboard.chats.chatsViewController()!
		let chatsRouter = BaseRouter(initialController: chatsVC)
		let chatsFlowCoordinator = MainFlow(router: chatsRouter, self)
        ChatsWireframe.setup(chatsVC, withCoordinator: chatsFlowCoordinator)
        chatsVC.index = 1
		
        let retweetsController = R.storyboard.tweetsForUser.tweetsForUserViewController()!
		let retweetsRouter = BaseRouter(initialController: retweetsController)
		let retweetsFlowCoordinator = MainFlow(router: retweetsRouter, self)
		retweetsController.index = 2
		UserRetweetsWireframe.setup(retweetsController, withCoordinator: retweetsFlowCoordinator) { presenter in
			presenter.user = (Session.current?.user)!
		}
		
		let mentionsController = R.storyboard.tweetsForUser.tweetsForUserViewController()!
		let mentionsRouter = BaseRouter(initialController: mentionsController)
		let mentionsFlowCoordinator = MainFlow(router: mentionsRouter, self)
        mentionsController.index = 3
		UserMentionsWireframe.setup(mentionsController,
		                            withCoordinator: mentionsFlowCoordinator) { (presenter) in
			presenter.user = (Session.current?.user)!
		}
        
        return [
            TopBarItem(view: TopBarItemContainerView.nibView()!, viewController: feedVC),
            TopBarItem(view: {
                let item = TopBarItemImageView.nibView()!
                item.image = #imageLiteral(resourceName: "page_messages_inactive")
				item.imageViewWidthConstraint.constant = 26
				item.imageViewHeightConstraint.constant = 25
                return item
            }(), viewController: chatsVC),
            TopBarItem(view: {
                let item = TopBarItemImageView.nibView()!
                item.image = #imageLiteral(resourceName: "page_retweet_inactive")
				item.imageViewWidthConstraint.constant = 30
				item.imageViewHeightConstraint.constant = 22
                return item
            }(), viewController: retweetsController),
            TopBarItem(view: {
                let item = TopBarItemImageView.nibView()!
                item.image = #imageLiteral(resourceName: "dog_inactive")
				item.imageViewWidthConstraint.constant = 26
				item.imageViewHeightConstraint.constant = 24
                return item
            }(), viewController: mentionsController)
        ]
    }
	
	private func createProfileVC() -> UIViewController? {
		guard let profileVC = R.storyboard.profile.profileViewController(),
		let user = Session.current?.user else {
			return nil
		}
		
		let router = BaseRouter(initialController: rootViewController)
		let profileFlow = ProfileFlow(router: router, self)
		ProfileWireframe.setup(profileVC, withCoordinator: profileFlow) { (configurator) in
			configurator.userId = user.id
			configurator.userScreenName = user.screenName
		}
		
		let navController = BaseNavigationController(rootViewController: profileVC)
		navController.view.backgroundColor = UIColor.white
		return navController
	}
}
