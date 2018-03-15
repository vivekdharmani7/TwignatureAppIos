//
//  TweetDetailsViewController.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 9/18/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

class TweetDetailsViewController: BaseViewController {
	
	var tweet: Tweet? {
		didSet {
			if let tweet = self.tweet {
				headerView.configureWith(replyTweet: tweet)
			}
		}
	}
	var presenter:  TweetDetailsPresenter!
	
	private weak var headerView: TweetDetailsHeaderView!
	private weak var footerView: TweetDetailsFooterView!
	fileprivate lazy var mediaViewerManager = self.configuredMediaViewManager()
	fileprivate var transitionMediaItem : MediaItem?
	
	@IBOutlet fileprivate weak var tableView: UITableView!
	
	var isMoreRepliesEnabled: Bool = true {
		didSet {
			footerView.isHidden = !isMoreRepliesEnabled
		}
	}
	
	func updateReplies(replies: [Tweet], reload: Bool) {
		if reload {
			repliesViewModels = replies
			tableView.reloadData()
			tableView.contentOffset.y = 0
		} else {
			addNewReplies(replies: replies)
		}
	}
    
    func update(with post: Post, at index: Int) {
        guard index < repliesViewModels.count else { return }
        repliesViewModels[index].seal = post.seal
		repliesViewModels[index].tweetReferenceId = post.tweetReferenceId ?? repliesViewModels[index].tweetReferenceId
    }
	
	private func addNewReplies(replies: [Tweet]) {
		guard !replies.isEmpty else {
			return
		}
		
		guard !repliesViewModels.isEmpty else {
			repliesViewModels = replies
			tableView.reloadData()
			return
		}
		
		let oldCount = repliesViewModels.count
		repliesViewModels.append(contentsOf: replies)
	
		tableView.beginUpdates()
		
		var indexes = [IndexPath]()
		for i in oldCount...oldCount + replies.count - 1 {
			let indexPath = IndexPath(row: i, section: 0)
			indexes.append(indexPath)
		}
		tableView.insertRows(at: indexes, with: UITableViewRowAnimation.bottom)
		
		tableView.endUpdates()
	}
	
    var repliesViewModels = [Tweet]()
	
	var inprogess : Bool = false {
		didSet {
			footerView?.inprogress = inprogess
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		registerNibs()
		presenter.viewDidReady()		
    }
	
	func updateTweet(updated: Tweet) {
		if tweet == updated {
			headerView.configureWith(replyTweet: updated)
			tweet = updated
			return
		}
		
		if let reply = repliesViewModels.first(where: { updated == $0 }),
			let ix = repliesViewModels.index(of: reply) {
			repliesViewModels[ix] = updated
			self.tableView.reloadData()
		}
	}
    
    func updateVisibleItems() {
        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        tableView.reloadRows(at: indexPaths, with: .none)
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		headerView.frame.size.height = headerView.getDesiredHeightFor(with: self.view.frame.width)
		footerView.frame.size.height = 80
	}
	
	private func configuredMediaViewManager() -> AKMediaViewerManager {
		let manager = AKMediaViewerManager()
		manager.delegate = self
		manager.elasticAnimation = false
		return manager
	}
	
	private func registerNibs() {
		tableView.register(R.nib.commentCell(), forCellReuseIdentifier: CommentCell.identifier)
	}
	
	private func configureInterface() {
		headerView = TweetDetailsHeaderView.nibView()
		headerView.delegate = self
		tableView.tableHeaderView = headerView
		footerView = TweetDetailsFooterView.nibView()
		tableView.tableFooterView = footerView
		footerView?.action = { [unowned self] in
			self.presenter.moreRepliesAction()
		}
		
        localizeViews()
		configureNavBar()
		tableView.dataSource = self
		tableView.delegate = self
    }
	
	private func configureNavBar() {
		let leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back"),
		                                        style: UIBarButtonItemStyle.plain,
		                                        target: self,
		                                        action: #selector(backDidClick))
		let rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_create_tweet_navitem"),
		                                         style: UIBarButtonItemStyle.plain,
		                                         target: self,
		                                         action: #selector(createTweetDidClick))
		
		navigationItem.leftBarButtonItem = leftBarButtonItem
		navigationItem.rightBarButtonItem = rightBarButtonItem
		navigationItem.titleView = UILabel()
		let label = UILabel()
		label.text = "Tweet"
		label.font = UIFont.boldSystemFont(ofSize: 22)
		label.sizeToFit()
		label.textColor = UIColor.black
		navigationItem.titleView = label
	}
	
	@IBAction private func addReplyDidTap(_ sender: Any) {
		presenter.addReplyAction()
	}
	
	dynamic
	private func backDidClick() {
		presenter.backAction()
	}
	
	dynamic
	private func createTweetDidClick() {
		presenter.addReplyAction()
	}
	
    private func localizeViews() {
    }
}

extension TweetDetailsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		let reply = repliesViewModels[indexPath.row]
		return CommentCell.calculateHeightFor(with: self.view.frame.width, andTweet: reply)
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		presenter.selectReplyAction(tweet: repliesViewModels[indexPath.row])
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension TweetDetailsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return repliesViewModels.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(resource: CommentCell.self, for: indexPath)
		let reply = repliesViewModels[indexPath.row]
		cell.configureWith(replyTweet: reply)
		cell.delegate = self
		return cell
	}
}

extension TweetDetailsViewController: TweetUserInteractive {
	
	// probably this should be in presenter
	
	func menuAction(tweet: Tweet, withSender sender: UIView) {
		presenter.menuAction(tweet: tweet, withSender: sender)
	}
	
	func replyAction(tweet : Tweet) {
		presenter.headerAddReplyAction(tweet)
	}
	
	func retweetAction(tweet : Tweet, withSender sender: UIView) {
		presenter.retweetAction(tweet: tweet, withSender: sender)
	}
	
	func likeAction(tweet : Tweet) {
		presenter.likeAction(tweet: tweet)
	}
	
	func messageAction(tweet : Tweet) {
		presenter.messageAction(tweet: tweet)
	}
    
    func sealAction(tweet: Tweet) {
        presenter.sealAction(tweet: tweet)
    }
	
	func mediaAction(item: MediaItem, transitionImageView: UIImageView? = nil) {
		guard let transitionImageView = transitionImageView else {
			return
		}
		
		transitionMediaItem = item
		mediaViewerManager.startFocusingView(transitionImageView)
	}
	
	func urlAction(url : URL) {
		presenter.linkAction(url)
	}
	
	func hashTagAction(tag : String) {
		presenter.hashtagAction(tag)
	}
	
	func mentionAction(user : MentionedUser) {
		presenter.mentionAction(user)
	}
	
	func avatarAction(user : User) {
		presenter.userAction(user: user)		
	}
	
	func showSensitiveAction() {
		presenter.showSensitiveAction()
	}
}

// MARK: - AKMediaViewerDelegate

extension TweetDetailsViewController: AKMediaViewerDelegate {
	
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
