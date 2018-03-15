//
//  ChatsViewController.swift
//  Twignature
//
//  Created by Anton Muratov on 9/14/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class ChatsViewController: BaseViewController, Indexable, Scrollable {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet fileprivate weak var createChatButton: FloatingButton!
	@IBOutlet private weak var noChatsLabel: UILabel!
	fileprivate var lastScrollOffset: CGFloat = 0
	fileprivate var isTweetButtonOutOfScreen = false
	fileprivate var viewModel: ChatsViewModel!
    var index: Int = 0
    var scrollCallback: Closure<CGFloat>!
    
    var presenter: ChatsPresenter!
    
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        presenter.viewIsReady()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		presenter.viewWillAppear()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		presenter.viewWillDisapear()
	}
	
    // MARK: - Actions
    
    func setup(with viewModel: ChatsViewModel) {
        self.viewModel = viewModel
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
		noChatsLabel.isHidden = !viewModel.chatItems.isEmpty
		tableView.isHidden = viewModel.chatItems.isEmpty
	}
    
    // MARK: - Private
    
    // MARK: - Configuration
    
    func configureTableView() {
		tableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        registerNibs()
    }
    
    private func registerNibs() {
		tableView.register(R.nib.chatCell)
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressCreateChat(_ sender: Any) {
        presenter.handleCreateChat()
    }
}

// MARK: - ChatsViewController

extension ChatsViewController: UITableViewDataSource {
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		scrollCallback?(scrollView.contentOffset.y)
		let isScrollingToBottom = scrollView.contentOffset.y > lastScrollOffset
		if isScrollingToBottom && !isTweetButtonOutOfScreen && scrollView.contentOffset.y > 0 {
			isTweetButtonOutOfScreen = true
			createChatButton.changeTweeterButtonVisibility(false)
		} else if !isScrollingToBottom && isTweetButtonOutOfScreen {
			isTweetButtonOutOfScreen = false
			createChatButton.changeTweeterButtonVisibility(false)
		}
		lastScrollOffset = scrollView.contentOffset.y
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			scrollingFinished()
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollingFinished()
	}
	
	func scrollingFinished() {
		isTweetButtonOutOfScreen = false
		createChatButton.changeTweeterButtonVisibility(true)
	}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewItem = viewModel.chatItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(resource: ChatCell.self, for: indexPath)
        cell.avatarView.imageView.setImage(with: viewItem.recipientAvatarUrl)
        cell.nameLabel.text = viewItem.recipientName
        cell.usernameLabel.text = "@\(viewItem.recipientTweeterName) "
        if viewItem.isVerified {
            cell.usernameLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
        }
        cell.lastMessageTextLabel.text = viewItem.text
        cell.timeAgoLabel.text = viewItem.lastMessageTime
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.cellTap(at: indexPath.row)
    }
    
}
