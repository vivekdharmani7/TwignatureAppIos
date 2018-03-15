//
//  OnBoardingTutorialProtocols.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol OnBoardingTutorialCoordinator: class {
	func startPresentingOfNextTutorial(_ sender: OnBoardingTutorialPresenter,
	                                   toState: TransitionState)
	func changeProgressOfPresenting(_ value: CGFloat,
	                                _ sender: OnBoardingTutorialPresenter)
	func endPresentingOfNextTutorial(_ sender: OnBoardingTutorialPresenter,
	                                 withProgress progress: CGFloat,
	                                 state: TransitionState)
	func skipButtonAction(_ sender: OnBoardingTutorialPresenter)
}
