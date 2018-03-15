//  FeedViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import TwitterKit
import ESPullToRefresh
import SideMenu
import DropDown

class FeedViewController: BaseViewController, Indexable, Scrollable, FeedControllerProtocol {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var createTweetButton: FloatingButton!
    @IBOutlet fileprivate weak var searchBar: DesignableTextField!
    @IBOutlet fileprivate weak var cancelSearchButton: UIButton!
	@IBOutlet fileprivate weak var notweetsLabel: UILabel!
	@IBOutlet fileprivate weak var textFieldContentViewTopContstraint: NSLayoutConstraint!
	@IBOutlet fileprivate weak var textFieldContentViewHeightContstraint: NSLayoutConstraint!

	fileprivate var lastScrollOffset: CGFloat = 0
	fileprivate var isTweetButtonOutOfScreen = false
	fileprivate lazy var mediaViewerManager = self.configuredMediaViewManager()

    fileprivate var viewModel: FeedViewModel!
	fileprivate var transitionMediaItem : MediaItem?
    fileprivate var filterDropDown: DropDown!
    
    var index: Int = 0
    var scrollCallback: Closure<CGFloat>!
    
    var presenter: FeedPresenter!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        configureTableView()
        configureFilterDropDown()
        presenter.viewIsReady()
		addPullToRefresh()
		tableView.es_addInfiniteScrolling { [weak self] in
			self?.presenter.loadNextItems()
		}
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 240
		tableView.contentInset = UIEdgeInsetsMake(textFieldContentViewHeightContstraint.constant, 0, 0, 0)
//        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
        notweetsLabel.text = nil
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.presenter.viewIsOnScreen()
	}

	func addPullToRefresh() {
		let footer = tableView.es_addPullToRefresh { [weak self] in
			self?.presenter.refreshTweets()
		}
		footer.refreshIdentifier = ""
	}

    // MARK: - Actions

	func setNewPostButton(_ isPro: Bool) {
		self.createTweetButton?.setImage(isPro ? #imageLiteral(resourceName: "pro_pen_icon") : #imageLiteral(resourceName: "pen_icon") , for: .normal)
	}

    func setup(with viewModel: FeedViewModel) {
		tableView.es_stopLoadingMore()
		tableView.es_stopPullToRefresh()
        self.viewModel = viewModel
        if let dataSource = viewModel.dataSource, case let FeedViewModel.DataSource.tweets(tweets) = dataSource {
            notweetsLabel.isHidden = !tweets.isEmpty
        }
		guard tableView.dataSource == nil else {
			tableView.reloadData()
			return
		}
		tableView.dataSource = self
		tableView.delegate = self
        tableView.reloadData()
    }
    
    func append(with tweets: [Tweet]) {
        tableView.es_stopLoadingMore()
        tableView.es_stopPullToRefresh()
        guard !tweets.isEmpty else { return }
        let firstIndex = viewModel.dataSource?.count ?? 0
        let lastIndex = firstIndex + tweets.count - 1
        let indexPathesIndexes = Array(firstIndex...lastIndex)
        let indexPathes = indexPathesIndexes.map { (index) -> IndexPath in
            return IndexPath(row: index, section: 0)
        }
        viewModel.append(tweets: tweets)
        if let dataSource = viewModel.dataSource, case let FeedViewModel.DataSource.tweets(tweets) = dataSource {
            notweetsLabel.isHidden = !tweets.isEmpty
        }
        guard tableView.dataSource == nil else {
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathes, with: UITableViewRowAnimation.automatic)
            tableView.endUpdates()
            return
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
	
	func scrollToTop() {
		tableView.contentOffset = CGPoint.zero
	}
	
	func stopLoadingMore() {
		tableView.es_stopLoadingMore()
	}
	
	func startPullToRefresh() {
		tableView.es_startPullToRefresh()
	}
	
	func stopPullToRefresh() {
		tableView.es_stopPullToRefresh()
	}
    
    func updateView(isSearchEnabled: Bool) {
        cancelSearchButton.isHidden = !isSearchEnabled
        searchBar.text = isSearchEnabled ? searchBar.text : nil
		if isSearchEnabled {
			tableView.es_removeRefreshHeader()
		} else {
			addPullToRefresh()
		}

    }
	
	func updateVisibleItems() {
		guard let indexPaths = tableView.indexPathsForVisibleRows else {
			return
		}
        tableView.beginUpdates()
		tableView.reloadRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
	}
	
    func updateTweetItem(at index: Int) {
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    // MARK: - Private
    
    // MARK: - IBActions
    
    @IBAction fileprivate func createTweetButtonDidTap(_ createTweetButton: UIButton) {
        presenter.createTweetTap()
    }
    
    @IBAction func filterButtonDidTap(_ sender: Any) {
        filterDropDown.show()
    }
    
    @IBAction func cancelSearchButtonDidTap(_ sender: Any) {
        presenter.finishSearch()
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Configuration
    
    private func configureFilterDropDown() {
        filterDropDown = DropDown(anchorView: searchBar)
        filterDropDown.backgroundColor = .white
        filterDropDown.tintColor = Color.twitterBlue
        filterDropDown.cornerRadius = Layout.floatCellCornerRadius
        filterDropDown.bottomOffset = CGPoint(x: 0, y: searchBar.bounds.height + 16)
        filterDropDown.dataSource = [FeedViewModel.SearchFilter.people.title, FeedViewModel.SearchFilter.tweets.title]
        filterDropDown.selectionAction = { [unowned self] index, item in
            let newFilter = FeedViewModel.SearchFilter(rawValue: index)!
            self.viewModel.searchFilter = newFilter
            self.presenter.handleFilterChange(filter: newFilter)
            self.filterDropDown.hide()
            self.filterDropDown.deselectRow(at: index)
            self.filterDropDown.reloadAllComponents()
        }
        filterDropDown.customCellConfiguration = { [unowned self] index, item, cell in
            let isSelected = self.viewModel.searchFilter.rawValue == index
            cell.accessoryType = isSelected ? .checkmark : .none
            cell.optionLabel?.textColor = isSelected ? .black : Color.lightGray
            cell.backgroundColor = .white
        }
    }
    
    private func configureTableView() {
        registerNibs()
    }
    
    private func registerNibs() {
        tableView.register(R.nib.tweetCell)
        tableView.register(R.nib.userCell)
    }
    
    // MARK: - Configured properties
	
	private func configuredMediaViewManager() -> AKMediaViewerManager {
		let manager = AKMediaViewerManager()
		manager.delegate = self
		manager.elasticAnimation = false
		return manager
	}
	
    // MARK: - Animations
    
    fileprivate func changeTweeterButtonVisibility(_ visible: Bool) {
		let topConstraintHeight = visible ? 0 : -textFieldContentViewHeightContstraint.constant
		self.textFieldContentViewTopContstraint.constant = topConstraintHeight
		self.createTweetButton.changeTweeterButtonVisibility(visible)
        UIView.animate(withDuration: 0.1, delay: 0.5, animations: { [unowned self] in
			self.view.layoutIfNeeded()
        })
    }
}

// MARK: - UITableViewDataSource

extension FeedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = viewModel.dataSource else { fatalError("data source not found") }
        switch dataSource {
        case .tweets(let tweets):
            return tweetCell(tableView, at: indexPath, viewItem: tweets[indexPath.row])
        case .users(let users):
            return userCell(tableView, at: indexPath, viewItem: users[indexPath.row])
        }
    }
    
    func tweetCell(_ tableView: UITableView, at indexPath: IndexPath, viewItem: FeedViewModel.TweetViewItem) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.tweetCell, for: indexPath)!
		TweetCellConfigurator.setupFields(for: cell, with: viewItem, indexPath: indexPath)
		TweetCellConfigurator.setupImage(for: cell, with: viewItem, at: indexPath, tableView: tableView)
        setupClosures(for: cell, with: viewItem, at: indexPath)
        return cell
    }
	
    func userCell(_ tableView: UITableView, at indexPath: IndexPath, viewItem: FeedViewModel.UserViewItem) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userCell, for: indexPath)!
        cell.avatarView.imageView.setImage(with: viewItem.avatarUrl)
        cell.hidesButton = true
        cell.nameLabel.text = viewItem.name
        cell.screenNameLabel.text = viewItem.screenName
        if viewItem.isVerified {
            cell.screenNameLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
        }
        return cell
    }
}

// MARK: - Cell configurations

extension FeedViewController {
	
	func dropLoadings() {
	}    
	
	fileprivate func setupClosures(for tweetCell: TweetCell,
                       with viewModelItem: FeedViewModel.TweetViewItem,
                       at indexPath: IndexPath) {
        tweetCell.replyTapCallback = { [unowned self] in
            self.presenter.replyTap(at: indexPath.row)
        }
        tweetCell.retweetTapCallback = { [unowned self, unowned tweetCell] in
			self.presenter.retweetTap(at: indexPath.row, withSender: tweetCell.retweetImageView)
        }
        tweetCell.likeTapCallback = { [unowned self] in
            self.presenter.likeTap(at: indexPath.row)
        }
        tweetCell.messageTapCallback = { [unowned self] in
            self.presenter.messageTap(at: indexPath.row)
        }
        tweetCell.hashtagTapCallback = { [unowned self] (hashtag) in
            self.presenter.hashtagTap(hashtag, at: indexPath.row)
        }
        tweetCell.mentionTapCallback = { [unowned self] (mention) in
            self.presenter.mentionTap(mention, at: indexPath.row)
        }
        tweetCell.linkTapCallback = { [unowned self] (link) in
            self.presenter.linkTap(link, at: indexPath.row)
        }
		tweetCell.locationTapCallback = { [unowned self] in
			self.presenter.locationDidTap(at: indexPath.row)
		}
		tweetCell.profileTapCallback = { (destination) in
			self.presenter.profileDidTap(at: indexPath.row, withDestination: destination)
		}
		tweetCell.sealTapCallback = { [unowned self] in
			self.presenter.sealDidTap(at: indexPath.row)
		}

		tweetCell.longTapCallback = { [unowned self, unowned tweetCell] in
			self.presenter.longTapAction(at: indexPath.row, withSender: tweetCell)
		}
		
		tweetCell.selectionStyle = .blue
		
        tweetCell.mediaTapCallback = { [unowned self] (mediaItem, imageView) in
			self.transitionMediaItem = mediaItem
			self.mediaViewerManager.startFocusingView(imageView)
        }
    }
}

// MARK: - UIScrollViewDelegate

extension FeedViewController: UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollCallback?(scrollView.contentOffset.y)
        let isScrollingToBottom = scrollView.contentOffset.y > lastScrollOffset
        if isScrollingToBottom && !isTweetButtonOutOfScreen && scrollView.contentOffset.y > 0 {
            isTweetButtonOutOfScreen = true
            changeTweeterButtonVisibility(false)
        } else if !isScrollingToBottom && isTweetButtonOutOfScreen {
            isTweetButtonOutOfScreen = false
            changeTweeterButtonVisibility(true)
        }
        lastScrollOffset = scrollView.contentOffset.y
    }
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			createTweetButton.changeTweeterButtonVisibility(false)
			scrollingFinished()
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		createTweetButton.changeTweeterButtonVisibility(false)
		scrollingFinished()
	}
	
	func scrollingFinished() {
		isTweetButtonOutOfScreen = false
		changeTweeterButtonVisibility(true)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = viewModel.dataSource else { fatalError("data source not found") }
        switch dataSource {
        case .tweets:
            presenter.tweetDetailsTap(at: indexPath.row)
        case .users:
            presenter.userTap(at: indexPath.row)
        }
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}

// MARK: - AKMediaViewerDelegate

extension FeedViewController: AKMediaViewerDelegate {
	
	func parentViewControllerForMediaViewerManager(_ manager: AKMediaViewerManager) -> UIViewController {
		return self
	}
	
	func mediaViewerManager(_ manager: AKMediaViewerManager, mediaURLForView view: UIView) -> URL {
		guard let mediaUrl = transitionMediaItem?.videoInfo?.items.first?.url
			?? transitionMediaItem?.mediaUrl else {
				let defaultFailSafeUrl = URL(string: "http://")!
				return defaultFailSafeUrl
		}
		return mediaUrl
	}
	
	func mediaViewerManager(_ manager: AKMediaViewerManager, titleForView view: UIView) -> String {
		return ""
	}
}

extension FeedViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        presenter.handleSearchInput(query: searchText, filter: viewModel.searchFilter)
        return true
    }
}
