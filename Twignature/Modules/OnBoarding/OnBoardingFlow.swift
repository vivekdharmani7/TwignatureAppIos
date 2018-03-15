//
//  OnBoardingFlow.swift
//  Twignature
//
//  Created by mac on 17.09.17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import Hero

struct OnBoardingTutorialSetups {
	let text: String!
	let background: UIImage!
}

class OnBoardingFlow {
	
	unowned fileprivate let appFlow: AppFlow
	fileprivate let pages:[OnBoardingTutorialSetups]
	fileprivate var currentIndex: Int = 0
	fileprivate var nextIndex: Int?
	
	init(appFlow: AppFlow) {
		self.appFlow = appFlow
		
		var onBoardingTexts: [String] = []
		var images: [UIImage] = [#imageLiteral(resourceName: "firstOnBoardingBackground"), #imageLiteral(resourceName: "secondOnBoardingBackground"), #imageLiteral(resourceName: "thirdOnBoardingBackground"), #imageLiteral(resourceName: "fourthOnBoardingBackground")]
		if Session.current?.user.isVerified ?? false {
			onBoardingTexts = [R.string.onBoarding.firstOnBoardingTextValid(),
							   R.string.onBoarding.secondOnBoardingTextValid(),
							   R.string.onBoarding.thirdOnBoardingTextValid(),
							   R.string.onBoarding.fourthOnBoardingTextValid()]
		} else {
			onBoardingTexts = [R.string.onBoarding.firstOnBoardingTextNonValid(),
			                   R.string.onBoarding.secondOnBoardingTextNonValid(),
			                   R.string.onBoarding.thirdOnBoardingTextNonValid(),
			                   R.string.onBoarding.fourthOnBoardingTextNonValid()]
		}
		var pages: [OnBoardingTutorialSetups] = []
		for (index, value) in onBoardingTexts.enumerated() {
			let image = images[index]
			let onBoardingSetup = OnBoardingTutorialSetups(text: value, background: image)
			pages.append(onBoardingSetup)
		}
		self.pages = pages
	}
	
	func initialOnBoarding() throws -> OnBoardingTutorialViewController {
		guard let initialViewController = R.storyboard.onBoarding.onBoardingTutorialViewController() else {
			throw TwignatureError.accessDenied
		}
		_ = initialViewController.view
		updateOnBoardingScreen(initialViewController, onPageNumber: currentIndex)
		return initialViewController
	}
	
	func updateOnBoardingScreen(_ screen: OnBoardingTutorialViewController,
	                            onPageNumber number: Int) {
		let page = pages[number]
		OnBoardingTutorialWireframe.setup(screen,
		                                  withCoordinator: self) { presenter in
											presenter.updateWithSetups(page)
											presenter.updatePageNumber(number)
		}
	}
	
	func nextViewControllerForIndex(_ index: Int) -> UIViewController {
		if index >= pages.count {
			if let isVerified = Session.current?.user.isVerified, isVerified {
				guard let nextViewController = R.storyboard.onBoarding.onBoardingAcceptViewController() else {
					return UIViewController()
				}
				_ = nextViewController.view
				OnBoardingAcceptWireframe.setup(nextViewController,
												withCoordinator: self)
				return nextViewController
			} else {
				return appFlow.mainFlowController()
			}
		} else {
			guard let nextViewController = R.storyboard.onBoarding.onBoardingTutorialViewController() else {
				return UIViewController()
			}
			_ = nextViewController.view
			updateOnBoardingScreen(nextViewController, onPageNumber: index)
			return nextViewController
		}
	}
}

extension OnBoardingFlow: OnBoardingTutorialCoordinator {
	
	func startPresentingOfNextTutorial(_ sender: OnBoardingTutorialPresenter,
	                                   toState: TransitionState) {
		Hero.shared.cancel(animate: false)
		let nextIndex = currentIndex + (toState == .slidingLeft ? 1 : -1)
		guard nextIndex >= 0, nextIndex < pages.count + 1 else {
			return
		}
		self.nextIndex = nextIndex
		let nextViewController = nextViewControllerForIndex(nextIndex)
		var direction = HeroDefaultAnimationType.Direction.right
		if toState == .slidingLeft {
				direction = HeroDefaultAnimationType.Direction.left
		}
		let transition = HeroDefaultAnimationType.slide(direction: direction)
		nextViewController.heroModalAnimationType = transition
		sender.controller.hero_replaceViewController(with: nextViewController)
	}
	
	func changeProgressOfPresenting(_ value: CGFloat,
	                                _ sender: OnBoardingTutorialPresenter) {
		Hero.shared.update(value)
	}
	
	func endPresentingOfNextTutorial(_ sender: OnBoardingTutorialPresenter,
	                                 withProgress progress: CGFloat,
	                                 state: TransitionState) {
		//track cancel
		if (progress < 0) == (state == .slidingLeft) && abs(progress) > 0.3 {
			Hero.shared.finish()
			currentIndex = nextIndex ?? currentIndex
		} else {
			Hero.shared.cancel()
		}
	}
	
	func skipButtonAction(_ sender: OnBoardingTutorialPresenter) {
		let nextViewController = nextViewControllerForIndex(pages.count + 1)
		let direction = HeroDefaultAnimationType.Direction.right
		let transition = HeroDefaultAnimationType.slide(direction: direction)
		nextViewController.heroModalAnimationType = transition
		sender.controller.hero_replaceViewController(with: nextViewController)
	}
}

extension OnBoardingFlow: OnBoardingAcceptCoordinator {
	
	func acceptButtonPressed() {
		UserDefaults.standard.set(true, forKey: Key.onBoardingPressented)
		appFlow.startMainFlow()
	}
}
