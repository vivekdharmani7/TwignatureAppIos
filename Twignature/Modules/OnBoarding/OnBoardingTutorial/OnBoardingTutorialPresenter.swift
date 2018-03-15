//
//  OnBoardingTutorialPresenter.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class OnBoardingTutorialPresenter {
    
    //MARK: - Init
    required init(controller: OnBoardingTutorialViewController,
                  interactor: OnBoardingTutorialInteractor,
                  coordinator: OnBoardingTutorialCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: OnBoardingTutorialCoordinator
    fileprivate(set) unowned var controller: OnBoardingTutorialViewController
    fileprivate var interactor: OnBoardingTutorialInteractor
	
	func updateWithSetups(_ setups: OnBoardingTutorialSetups) {
		controller.setBackgroundImage(setups.background)
		controller.setPageDescription(setups.text)
	}
	
	func updatePageNumber(_ number: Int) {
		controller.setPageControlPageNumber(number)
	}
	
	func setPagesCount(_ number: Int) {
		controller.setNumberOfPages(number)
	}
	
	//MARK: View output
	func didStartSwipingAction(toState: TransitionState) {
		coordinator.startPresentingOfNextTutorial(self, toState: toState)
	}
	
	func didChangeSwipeActionValue(_ progress: CGFloat) {
		coordinator.changeProgressOfPresenting(progress, self)
	}
	
	func didEndSwipingAction(withProgress progress: CGFloat, state: TransitionState) {
		coordinator.endPresentingOfNextTutorial(self, withProgress: progress, state: state)
	}
	
	func skipButtonAction() {
		coordinator.skipButtonAction(self)
	}
}
