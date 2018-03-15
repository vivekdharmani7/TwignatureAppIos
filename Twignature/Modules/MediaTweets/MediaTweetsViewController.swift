//
//  MediaTweetsViewController.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/9/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import ActiveLabel
import SHGalleryView

class MediaTweetsViewController: BaseViewController {
    //MARK: - Properties
    var presenter:  MediaTweetsPresenter!
	fileprivate var dataSource: MediaTweetsDataSource?
	@IBOutlet private weak var galeryContainerView: UIView!
	fileprivate var galleryView: SHGalleryView!
	@IBOutlet fileprivate weak var titleLabel: UILabel!
	@IBOutlet fileprivate weak var textLabel: ActiveLabel!
	@IBOutlet fileprivate weak var tweetContainer: UIView!
	
    //MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
		presenter.viewIsReady()
    }
	
	private func configureGallery() {
		let galleryView = SHGalleryView()
		galeryContainerView.addSubview(galleryView)
		galleryView.pinToSuperview()
		self.galleryView = galleryView
		let theme = SHGalleryViewTheme()
		theme.playButtonImage = #imageLiteral(resourceName: "ic_play")
		theme.pauseButtonImage = R.image.icon_pause()
		theme.pageControlDotColor = UIColor.gray
		theme.pageControlCurrentDotColor = UIColor.blue
		theme.sliderTrackColor = UIColor.lightGray
		theme.sliderProgressColor = UIColor.red
		theme.timeLabelAtributes =  [NSFontAttributeName : UIFont.systemFont(ofSize: 15),
		                             NSForegroundColorAttributeName : UIColor.white]
		
		galleryView.theme = theme
		galleryView.isDoneButtonForcedHidden = true
		galleryView.showPageControl = true
		galleryView.delegate = self
		galleryView.dataSource = self
		galleryView.setupGalleryView()
	}
	
	private func configureLabel() {
		textLabel.enabledTypes = [.hashtag, .mention, .url]
		textLabel.hashtagColor = Color.link
		textLabel.mentionColor = Color.link
		textLabel.URLColor = Color.link
		textLabel.handleURLTap { [weak self] (url) in
			self?.presenter.linkAction(url)
		}
		textLabel.handleHashtagTap { [weak self] (hashtag) in
			self?.presenter.hashtagAction(hashtag)
		}
		textLabel.handleMentionTap { [weak self] (mention) in
			self?.presenter.mentionAction(mention)
		}
	}
	
	func configureWith(_ dataSource: MediaTweetsDataSource, initialItemIndex: Int) {
		self.dataSource = dataSource
		showTweetInfo(for: initialItemIndex)
		guard dataSource.count > initialItemIndex else {
			return
		}
		galleryView.reloadData()
		galleryView.scrollToItem(at: Int32(initialItemIndex))
		setpageControlPage(currentPage: initialItemIndex)
		fixMediaIfneeded(currentPage: initialItemIndex)
	}
	
	private func setpageControlPage(currentPage: Int) { // workaround: needed to set page indicator in correct position on startup
		galleryView?.subviews.forEach { child in
			(child as? UIPageControl)?.currentPage = currentPage
		}
	}
	
	private func fixMediaIfneeded(currentPage: Int) { // workaround: needed to show video controls on startup when it's video item
		guard dataSource?.mediaItems[currentPage].type == .video else {
			return
		}
		
		let mediaView = galleryView?.subviews.first(where: { child in
			return (child as? SHMediaControlView) != nil
		}) as? SHMediaControlView
		guard let mediaControlView = mediaView else {
			return
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
			mediaControlView.subviews.forEach { $0.isHidden = false }
		}
	}
	
    //MARK: - UI
    
    private func configureInterface() {
		view.backgroundColor = UIColor.black
		configureGallery()
		configureLabel()
    }

	@IBAction func closeDidTap(_ sender: Any) {
		doneClicked()
	}
}

extension MediaTweetsViewController: SHGalleryViewControllerDataSource {
	func numberOfItems() -> CGFloat {
		return CGFloat(dataSource?.count ?? 0)
	}
	
	func mediaItemIndex(_ index: Int) -> SHMediaItem? {
		guard let source = dataSource else {
			return nil
		}
		
		let media = source.mediaItems[index]
		let isVideo: Bool = (media.type == .video)
		let imageUrl = media.mediaUrl
		let videoUrl = media.videoInfo?
			.items
			.sorted(by: { ($0.bitrate ?? 0) < ($1.bitrate ?? 0) })
			.first(where: { $0.contentType == .videoMp4 })?
			.url
		
		let mediaURL = videoUrl ?? imageUrl
		let path = mediaURL?.absoluteString ?? ""
		let mediaType = isVideo ? kMediaType.mediaTypeVideo : kMediaType.mediaTypeImage
		let item = SHMediaItem(mediaType: mediaType, andPath: path)!
		item.mediaThumbnailImagePath = imageUrl?.absoluteString
		return item
	}
}

extension MediaTweetsViewController: SHGalleryViewControllerDelegate {
	func galleryView(_ galleryView: SHGalleryView!, willDisplayItemAt index: Int32) {
		
	}
	
	func galleryView(_ galleryView: SHGalleryView!, didDisplayItemAt index: Int32) {
		showTweetInfo(for: Int(index))
	}
	
	fileprivate func showTweetInfo(for index: Int) {
		guard let source = dataSource,
			let tweet = source.tweetForMedia(at: index) else {
				return
		}
		
		textLabel.text = tweet.tweetInfo.text
		tweetContainer.isHidden = tweet.tweetInfo.text.isEmpty
	}
	
	func supportedOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.all.rawValue)
	}
	
	func doneClicked() {
		retainWorkaround()
		presenter.closeAction()
	}
	
	private func retainWorkaround() {
		// workaround: to avoid crash inside SHGallery
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
			self.dataSource = nil
		}
	}
}
