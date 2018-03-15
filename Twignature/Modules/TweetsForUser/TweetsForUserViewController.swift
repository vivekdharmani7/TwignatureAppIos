//
//  TweetsForUserViewController.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class TweetsForUserViewController: BaseViewController, Indexable, Scrollable {
	var index: Int = 0
	
	var scrollCallback: ((CGFloat) -> Void)!
	
    //MARK: - Properties
    var presenter:  TweetsForUserPresenter!
	var avatarURL: URL? {
		didSet {
			avatarView?.imageView.setImage(with: avatarURL)
		}
	}

	@IBOutlet fileprivate(set) weak var tableView: UITableView!
	@IBOutlet private weak var nodataLabel: UILabel!
	
	fileprivate lazy var mediaViewerManager = self.configuredMediaViewManager()
	
	fileprivate var lastScrollOffset: CGFloat = 0
	fileprivate var viewModel: FeedViewModel!
	fileprivate var transitionMediaItem : MediaItem?
    private weak var avatarView: AvatarContainerView?
    //MARK: - Life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
    }
    
    //MARK: - UI
    
    private func configureInterface() {
		configureNavBar()
        localizeViews()
		configureTableView()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 240
    }
	
	private func configureNavBar() {
		let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"),
		                                        style: UIBarButtonItemStyle.plain,
		                                        target: self,
		                                        action: #selector(backDidClick))
		
		navigationItem.leftBarButtonItem = leftBarButtonItem
		
		let avatarView = AvatarContainerView()
		let navBarHeight = navigationController?.navigationBar.intrinsicContentSize.height ?? 44
		let avatarHeight = navBarHeight - 4
		avatarView.frame.size = CGSize(width: avatarHeight, height: avatarHeight)
		navigationItem.titleView = avatarView
		self.avatarView = avatarView
	}
    
    private func localizeViews() {
    }
	
	dynamic
	private func backDidClick() {
		presenter.backAction()
	}
	
	// MARK: - Actions
	
	var textForNodata: String? {
		didSet {
			nodataLabel.text = textForNodata
		}
	}
	
	func setup(with viewModel: FeedViewModel) {
		tableView.es_stopLoadingMore()
		tableView.es_stopPullToRefresh()
		self.viewModel = viewModel
		if let dataSource = viewModel.dataSource, case let FeedViewModel.DataSource.tweets(tweets) = dataSource {
			nodataLabel.isHidden = !tweets.isEmpty
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
            nodataLabel.isHidden = !tweets.isEmpty
        }
        guard tableView.dataSource == nil else {
            tableView.beginUpdates()
            tableView.insertRows(at: indexPathes, with: UITableViewRowAnimation.bottom)
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
	
	func updateVisibleItems() {
		guard let indexPaths = tableView.indexPathsForVisibleRows else {
			return
		}
		tableView.reloadRows(at: indexPaths, with: .none)
	}
	
	func updateTweetItem(at index: Int) {
		tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
	}
	
	// MARK: - Configuration
	
	private func configureTableView() {
		registerNibs()
		tableView.es_addPullToRefresh { [weak self] in
			self?.presenter.refreshTweets()
		}
		tableView.es_addInfiniteScrolling { [weak self] in
			self?.presenter.loadNextTweets()
		}
	}
	
	private func registerNibs() {
		tableView.register(R.nib.tweetCell)
	}
	
	// MARK: - Configured properties
	
	private func configuredMediaViewManager() -> AKMediaViewerManager {
		let manager = AKMediaViewerManager()
		manager.delegate = self
		manager.elasticAnimation = false
		return manager
	}
}

// MARK: - UITableViewDataSource

extension TweetsForUserViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.dataSource?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataSource = self.viewModel?.dataSource,
            case let FeedViewModel.DataSource.tweets(tweets) = dataSource else { fatalError("data source not found") }
        let viewItem = tweets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.tweetCell, for: indexPath)!
		TweetCellConfigurator.setupFields(for: cell, with: viewItem, indexPath: indexPath)
		TweetCellConfigurator.setupImage(for: cell, with: viewItem, at: indexPath, tableView: tableView)
		setupClosures(for: cell, with: viewItem, at: indexPath)
		return cell
	}


	private func setupClosures(for tweetCell: TweetCell,
	                   with viewModelItem: FeedViewModel.TweetViewItem,
	                   at indexPath: IndexPath) {
		tweetCell.replyTapCallback = { [unowned self] in
			self.presenter.replyTap(at: indexPath.row)
		}
		tweetCell.retweetTapCallback = { [unowned self, unowned tweetCell] in
			self.presenter.retweetTap(at: indexPath.row, withSender: tweetCell.retweetImageView)
		}
		tweetCell.likeTapCallback = { [unowned self, unowned tweetCell] in
			tweetCell.likeControl.isEnabled = false
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
		tweetCell.profileTapCallback = { [unowned self] (destination) in
			self.presenter.profileDidTap(at: indexPath.row, withDestination: destination)
		}
		tweetCell.sealTapCallback = {[unowned self] in
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

extension TweetsForUserViewController: UITableViewDelegate {
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if !decelerate {
			scrollingFinished()
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		scrollingFinished()
	}
	
	func scrollingFinished() {

	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		presenter.tweetDetailsTap(at: indexPath.row)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
}

extension TweetsForUserViewController: AKMediaViewerDelegate {
	
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
