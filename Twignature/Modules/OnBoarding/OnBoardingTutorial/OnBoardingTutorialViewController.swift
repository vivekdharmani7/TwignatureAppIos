//
//  OnBoardingTutorialViewController.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import Hero

enum TransitionState {
	case normal, slidingLeft, slidingRight
}

class OnBoardingTutorialViewController: UIViewController {

	@IBOutlet private weak var sizeDefinedLabel: UILabel!
	@IBOutlet private weak var backgroundImageView: UIImageView!
	@IBOutlet private weak var descriptionTextView: UITextView!
	@IBOutlet private weak var pageControlView: UIPageControl!
	
	var state: TransitionState = .normal
	
    //MARK: - Properties
    var presenter:  OnBoardingTutorialPresenter!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		addSwipeGesture()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		descriptionTextView.contentOffset = CGPoint(x: 0, y: 0)
	}
	
	//MARK: - PUBLIC ACTIONS
	func setNumberOfPages(_ pagesCount: Int) {
		pageControlView.numberOfPages = pagesCount
	}
	
	func setBackgroundImage(_ image: UIImage!) {
		backgroundImageView.image = image
	}
	
	func setPageControlPageNumber(_ number: Int!) {
		pageControlView.currentPage = number
	}
	
	func setPageDescription(_ pageDescription: String!) {
		descriptionTextView.text = pageDescription
		sizeDefinedLabel.text = pageDescription
		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		descriptionTextView.contentOffset = CGPoint(x: 0, y: 0)
	}
    
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
//		backgroundImageView.layer.opacity = 0.35
    }
    
    private func localizeViews() {
    }
	
	private func addSwipeGesture() {
		let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
		view.addGestureRecognizer(gesture)
	}
	
	func handlePan(gestureRecognizer:UIPanGestureRecognizer) {
		
		let translateX = gestureRecognizer.translation(in: nil).x
		let velocityX = gestureRecognizer.velocity(in: nil).x
		switch gestureRecognizer.state {
		case .began, .changed:
			let nextState: TransitionState
			if state == .normal {
				nextState = velocityX < 0 ? .slidingLeft : .slidingRight
			} else {
				nextState = translateX < 0 ? .slidingLeft : .slidingRight
			}
			
			if nextState != state {
				Hero.shared.cancel(animate: false)
				presenter.didStartSwipingAction(toState: nextState)
				state = nextState
			} else {
				let progress = abs(translateX / view.bounds.width)
				presenter.didChangeSwipeActionValue(progress)
			}
		default:
			let progress = (translateX + velocityX) / view.bounds.width
			presenter.didEndSwipingAction(withProgress: progress, state: state)
			state = .normal
		}
	}
	
	@IBAction private func skipButtonPressed(_ sender: UIButton) {
		presenter.skipButtonAction()
	}
	
}
