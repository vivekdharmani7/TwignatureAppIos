//
//  TopBarController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import SideMenu

protocol Indexable {
    var index: Int { get set }
}

protocol Scrollable {
    var scrollCallback: Closure<CGFloat>! { get set }
}

class TopBarItem {
    let view: TopBarItemView
    var viewController: UIViewController
    
    init(view: TopBarItemView, viewController: UIViewController) {
        self.view = view
        self.viewController = viewController
    }
}

fileprivate let topBarHeight: CGFloat = 74

class TopBarController: UIViewController {
    
    //MARK: - Outlets

    @IBOutlet fileprivate weak var topBar: UIStackView!
    @IBOutlet fileprivate weak var contentView: UIView!
    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    
    fileprivate let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                              navigationOrientation: .horizontal,
                                                              options: nil)
    fileprivate var prevPage: Int?
    fileprivate var currentPage: Int = 0 {
        didSet { reload(for: currentPage) }
    }
    fileprivate var items: [TopBarItem] = []
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        attach(vc: pageViewController)
        contentView.addSubview(pageViewController.view)
        reload(for: 0)
    }
    
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
		guard let profileImageUrl = Session.current?.user.profileImageUrl else {
			return
		}
		updateProfileImage(withUrl: profileImageUrl )
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIInterfaceOrientation.portrait
	}
    
    override var shouldAutorotate: Bool {
        return false
    }
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController.view.frame = contentView.bounds
    }
    
    //MARK: - Public
    
    func configure(topBarItems items: [TopBarItem]) {
        self.items = items
        items.forEach { item in
			if  var scrollAble = item.viewController as? Scrollable {
				scrollAble.scrollCallback = { offset in
					// todo
				}
			}
        }
    }
    
    //MARK: - Private
    
    private func collapseTopBar(value: CGFloat) {
        guard value >= 0 && value <= 1 else { return }
        let barHeightDelta = (topBarHeight - Layout.navigationBarHeight) * (1 - value)
        topBarHeightConstraint.constant = Layout.navigationBarHeight + barHeightDelta
        view.layoutIfNeeded()
//        topBar.arrangedSubviews.map { $0 as? TopBarItemView }.forEach { item in
//            item?.collapse(value: value)
//        }
    }
    
    private func reload(for page: Int) {
        guard page >= 0 && page < items.count else { return }
        guard let barItem = topBar.arrangedSubviews[page] as? TopBarItemView else { return }
        
        var direction: UIPageViewControllerNavigationDirection?
        
        // deselect prev selected item if needed
        if let prevPage = prevPage,
            let prevItem = topBar.arrangedSubviews[prevPage] as? TopBarItemView {
            prevItem.selected = false
            direction = prevPage > page ? .reverse : .forward
        }
		
		if self.prevPage == page, page == 0 {
			self.present(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
		}
        self.prevPage = page
        barItem.selected = true
        pageViewController.setViewControllers([items[page].viewController],
                                              direction: direction ?? .forward,
                                              animated: direction != nil,
                                              completion: nil)
    }
    
    private func configureViews() {
        clearTopBar()
        items.enumerated().forEach { index, item in
            item.view.selectionClosure = { [unowned self] in
                self.reload(for: index)
            }
            topBar.addArrangedSubview(item.view)
        }
    }
	
	private func updateProfileImage(withUrl url: URL) {
		guard let profileItem = topBar.arrangedSubviews[0] as? TopBarItemContainerView else {
			return
		}
		profileItem.avatarContainer.imageView.setImage(with: url)
	}
    
    private func clearTopBar() {
        for i in 0..<topBar.arrangedSubviews.count {
            topBar.removeArrangedSubview(topBar.arrangedSubviews[i])
        }
    }
}
