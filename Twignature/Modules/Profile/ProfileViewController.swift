//
//  ProfileViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import ActiveLabel

private let baseHeaderHeight: CGFloat = 330

class ProfileViewController: BaseViewController {
    @IBOutlet fileprivate weak var messageButton: UIControl!
    @IBOutlet fileprivate weak var closeButton: UIControl!
    @IBOutlet fileprivate weak var nameContainerView: UIStackView!
    @IBOutlet fileprivate weak var avatarView: UIImageView!
    @IBOutlet fileprivate weak var backgroundAvatarView: UIImageView!
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    @IBOutlet fileprivate weak var nickLabel: UILabel!

    @IBOutlet fileprivate weak var locationLabel: UILabel!
    @IBOutlet fileprivate weak var followButton: UIButton!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var profileHeaderView: UIView!
    @IBOutlet fileprivate weak var headerHeightConstraint: NSLayoutConstraint!
	@IBOutlet private weak var optionsButton: UIButton!

	//MARK: - Properties
    var presenter:  ProfilePresenter!
	fileprivate var currentMediaUrl: URL?
	fileprivate lazy var mediaViewerManager = self.configuredMediaViewManager()
	
	fileprivate var sections: [Section] = []
	
	var isCloseEnabled: Bool = true {
		didSet {
			closeButton.isHidden = !isCloseEnabled
		}
	}
	
	var availableForFriendship: Bool = false {
		didSet {
			followButton.isHidden = !availableForFriendship
			optionsButton.isHidden = !availableForFriendship
			messageButton.isHidden = !availableForFriendship
		}
	}
	
	var isFollowing: Bool = false {
		didSet {
			followButton.isUserInteractionEnabled = true
			followButton.setTitle(isFollowing ? "Following" : "Follow", for: .normal)
			followButton.backgroundColor = isFollowing ? UIColor.tn_following : UIColor.tn_follow
		}
	}
	
	//MARK: - Life cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.setNavigationBarHidden(true, animated: true)
        presenter.viewIsReady()
	}
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Public
	
	func setToBlockedState(header: HeaderViewModel) {
		descriptionCell.setToBlockedState(blockedBy: header.screenName)
		followButton.isEnabled = false
		messageButton.isHidden = true
	}
	
    func configure(header: HeaderViewModel) {
        self.nameLabel.text = header.name
        self.nickLabel.text = header.screenName
        if header.isVerified {
            self.nickLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
        }
        self.locationLabel.text = header.location
        self.avatarView.kf.setImage(with: header.avatarUrl)
        self.backgroundAvatarView.kf.setImage(with: header.backgroundUrl)
	
		if !hasHeaderHeightOnceConfigured {
			hasHeaderHeightOnceConfigured = true
			updateHeaderHeight(baseHeaderHeight)
		}
		
		sections = [ Section.description ]
		descriptionCell.configure(header: header)
		tableView.reloadData()
    }
	
	private var hasHeaderHeightOnceConfigured = false
	
    func configure(details: Details, media: [MediaItem]) {
        sections = []
		sections.append(Section.description)
        configure(details: details)
        configure(mediaItems: media)
        tableView.reloadData()
    }	
	
    private func configure(details: Details) {
        let details = Section.details(rows: [
            FloatingTitledCell.ViewModel(title: R.string.profile.following(),
                                         countTitle: details.following,
                                         selectionClosure: { [weak self] in
                                            self?.presenter.showFollowingAction()
            }),
            FloatingTitledCell.ViewModel(title: R.string.profile.followers(),
                                         countTitle: details.followers,
                                         selectionClosure: { [weak self] in
                                            self?.presenter.showFollowersAction()
            }),
            FloatingTitledCell.ViewModel(title: R.string.profile.mentions(),
                                         countTitle: nil,
                                         selectionClosure: { [weak self] in
											self?.presenter.showMentionsAction()
			}),
            FloatingTitledCell.ViewModel(title: R.string.profile.likes(),
                                         countTitle: details.likes,
                                         selectionClosure: { [weak self] in
                                            self?.presenter.showLikesAction()
            }),
            FloatingTitledCell.ViewModel(title: R.string.profile.tweets(),
                                         countTitle: details.tweets,
                                         selectionClosure: { [weak self] in
											self?.presenter.showTweetsAction()
										})
        ])
        sections.append(details)
    }
    
    private func configure(mediaItems: [MediaItem]) {
		let media = Section.media(title: R.string.profile.media(), items: mediaItems)
        sections.append(media)
    }
    
    //MARK: - UI
    
    private func configureInterface() {
        profileHeaderView.clipsToBounds = true
        localizeViews()
        configureTableView()
    }
	
    private func configureTableView() {
		tableView.register(R.nib.profileHeaderDescriptionCellTableViewCell)
        tableView.register(R.nib.floatingTitledCell)
        tableView.register(R.nib.mediaCell)
		descriptionCell = createDescriptionCell()
    }
    
    private func localizeViews() {
        followButton.setTitle(R.string.profile.following(), for: .normal)
    }
    
    // MARK: - Private
    
    fileprivate func collapseHeader() {
        guard headerHeightConstraint.constant != Layout.navigationBarHeight else { return }
        UIView.animate(withDuration: 0.2) { 
            self.updateHeaderHeight(Layout.navigationBarHeight)
        }
    }
    
    fileprivate func revealHeader() {
        guard headerHeightConstraint.constant != baseHeaderHeight else { return }
        UIView.animate(withDuration: 0.2) { [unowned self] in
			self.updateHeaderHeight(baseHeaderHeight)
        }
    }
    
    fileprivate func updateHeaderHeight(_ height: CGFloat) {
        let currentOffset = height - Layout.navigationBarHeight
        let range = baseHeaderHeight - Layout.navigationBarHeight
        let value = 1 - currentOffset / range
        
        collapseAvatar(value: value)
        collapseCloseButton(value: value)
        collapseMessageButton(value: value)

		headerHeightConstraint.constant = height

        view.layoutIfNeeded()
    }
    
    private func collapseCloseButton(value: CGFloat) {
        let identity = CGAffineTransform.identity
        let collapsedY = (Layout.navigationBarHeight - Layout.statusBarHeight) / 2 + Layout.statusBarHeight
        
        let closeButtonTranslateTotalDistance = closeButton.center.y - collapsedY
        let closeButtonTranslateDistance = -(closeButtonTranslateTotalDistance * value)
        closeButton.transform = identity.translatedBy(x: 0, y: closeButtonTranslateDistance)
        
        let closeButtonScaleFactor = (1 - 0.3 * value)
        closeButton.transform = closeButton.transform.scaledBy(x: closeButtonScaleFactor, y: closeButtonScaleFactor)
    }
    
    private func collapseMessageButton(value: CGFloat) {
        let identity = CGAffineTransform.identity
        let collapsedY = (Layout.navigationBarHeight - Layout.statusBarHeight) / 2 + Layout.statusBarHeight
        
        let messageButtonTranslateTotalDistance = closeButton.center.y - collapsedY
        let messageButtonTranslateDistance = -(messageButtonTranslateTotalDistance * value)
        messageButton.transform = identity.translatedBy(x: 0, y: messageButtonTranslateDistance)
        
        let messageButtonScaleFactor = (1 - 0.3 * value)
        messageButton.transform = messageButton.transform.scaledBy(x: messageButtonScaleFactor, y: messageButtonScaleFactor)
    }
    
    private func collapseAvatar(value: CGFloat) {
        let identity = CGAffineTransform.identity
        
        let collapsedY = (Layout.navigationBarHeight - Layout.statusBarHeight) / 2 + Layout.statusBarHeight
        
        let avatarScaleValue: CGFloat = 0.7
        let nameLabelScaleValue: CGFloat = 0.5
        
        let avatarScaleFactor = (1 - value * avatarScaleValue)
        let nameLabelScaleFactor = (1 - value * nameLabelScaleValue)
        
        let collapsedAvatarWidth = (1 - avatarScaleValue) * avatarView.bounds.width
        let collapsedNameLabelWidth = (1 - nameLabelScaleValue) * nameLabel.textRect(forBounds: nameLabel.bounds,
                                                                                     limitedToNumberOfLines: 1).width
        
        let inset: CGFloat = 8
        let totalTitleWidth = collapsedAvatarWidth + inset + collapsedNameLabelWidth
        
        let avatarSupposedCenterX = profileHeaderView.bounds.width / 2 - totalTitleWidth / 2 + collapsedAvatarWidth / 2
        let avatarXTranslateTotalDistance = avatarSupposedCenterX - avatarView.center.x
        let avatarXTranslateDistance = value * avatarXTranslateTotalDistance
        
        let nameLabelSupposedCenterX = profileHeaderView.bounds.width / 2 - totalTitleWidth / 2 + collapsedAvatarWidth
            + inset + collapsedNameLabelWidth / 2
        let nameLabelXTranslateTotalDistance = nameLabelSupposedCenterX - nameLabel.center.x
        let nameLabelXTranslateDistance = value * nameLabelXTranslateTotalDistance
        
        let avatarYTranslateTotalDistance = avatarView.center.y - collapsedY
        let avatarYTranslateDistance = -(avatarYTranslateTotalDistance * value)
        avatarView.transform = identity.translatedBy(x: avatarXTranslateDistance, y: avatarYTranslateDistance)
        
        let nameLabelConvertedCenter = nameContainerView.convert(CGPoint(x: nameLabel.bounds.midX, y: nameLabel.bounds.midY),
                                                                 to: profileHeaderView)
        let nameLabelYTranslateTotalDistance = nameLabelConvertedCenter.y - collapsedY
        let nameLabelYTranslateDistance = -(nameLabelYTranslateTotalDistance * value)
        nameLabel.transform = identity.translatedBy(x: nameLabelXTranslateDistance, y: nameLabelYTranslateDistance)
        
        avatarView.transform = avatarView.transform.scaledBy(x: avatarScaleFactor, y: avatarScaleFactor)
        nameLabel.transform = nameLabel.transform.scaledBy(x: nameLabelScaleFactor, y: nameLabelScaleFactor)
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressmessage(_ sender: Any) {
		presenter.directMessageAction()
    }
    
    @IBAction fileprivate func didPressFollow(_ sender: UIButton) {
		followButton.isUserInteractionEnabled = false
		presenter.togglefollowAction(sender)
    }
	
	dynamic
	fileprivate func linkDidTap(_ sender: Any) {
		presenter.profileLinkAction()
	}
	
	@IBAction fileprivate func didPressSun(_ sender: UIButton) {
		presenter.optionsAction(sender)
    }
    
    @IBAction func didPressClose(_ sender: Any) {
        presenter.closeTap()
    }
	
	fileprivate var descriptionCell: ProfileHeaderDescriptionCellTableViewCell!
	
	private func createDescriptionCell() -> ProfileHeaderDescriptionCellTableViewCell? {
		let identifier = R.nib.profileHeaderDescriptionCellTableViewCell.identifier
		guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? ProfileHeaderDescriptionCellTableViewCell else {
			return nil
		}
		cell.linkButton.addTarget(self, action: #selector(linkDidTap), for: .touchUpInside)
		return cell
	}
}

extension ProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
		case .description:
			return 1
        case .details(let rows):
            return rows.count
        case .media:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
		case .description:
			return descriptionCell
        case .details(let rows):
            let row = rows[indexPath.row]
			let identifier = R.nib.floatingTitledCell.identifier
			guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? FloatingTitledCell else {
				return UITableViewCell()
			}

            cell.viewModel = row
            return cell
        case .media(_, let items):
			guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.mediaCell.identifier) as? MediaCell else {
				return UITableViewCell()
			}
			cell.delegate = self
			cell.mediaItems = items
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
		case .description:
			return nil
        case .details:
            return nil
        case .media:
            let header = MediaHeaderView.nibView()
            header?.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
            header?.titleLabel.text = R.string.profile.media()
            header?.button.setTitle(R.string.profile.viewAll(), for: .normal)
            header?.buttonCallback = {
                
            }
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
		case .description:
			return 0
        case .details:
            return 0
        case .media:
            return 50
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
		case .description:
			return descriptionCell.calculateHeight()
        case .details:
            return 71
        case .media(_, let items):
            let mediaCellWidth = (tableView.bounds.width - Layout.mediaCellSpacing * 4) / 3		
            let rows = ceil(CGFloat(items.count) / 3)
            return rows * mediaCellWidth + (rows - 1) * Layout.mediaCellSpacing + Layout.mediaCellSpacing * 2
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y
        
        let isScrollingDown = scrollDiff > 0
        let isScrollingUp = scrollDiff < 0
        
        var newHeight = self.headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(Layout.navigationBarHeight, headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(baseHeaderHeight, headerHeightConstraint.constant + abs(scrollDiff))
        }
        
        if newHeight != self.headerHeightConstraint.constant {
            self.tableView.set(scrollPosition: 0)
            updateHeaderHeight(newHeight)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let shouldCollapseHeader = (self.headerHeightConstraint.constant / baseHeaderHeight).rounded() == 0
        if shouldCollapseHeader {
            collapseHeader()
        } else {
            revealHeader()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        let shouldCollapseHeader = (self.headerHeightConstraint.constant / baseHeaderHeight).rounded() == 0
        if shouldCollapseHeader {
            collapseHeader()
        } else {
            revealHeader()
        }
    }
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		switch sections[indexPath.section] {
		case .description:
			break
		case .details(let rows):
			rows[indexPath.row].selectionClosure?()
		case .media:
			break
		}
	}

}

extension ProfileViewController: MediasViewDelegate {
	func itemAction(item: MediaItem, transitionImageView: UIImageView) {
		presenter.mediaAction(mediaItem: item)
	}
}

extension ProfileViewController: AKMediaViewerDelegate {	
	fileprivate func configuredMediaViewManager() -> AKMediaViewerManager {
		let manager = AKMediaViewerManager()
		manager.delegate = self
		manager.elasticAnimation = false
		return manager
	}
	
	func parentViewControllerForMediaViewerManager(_ manager: AKMediaViewerManager) -> UIViewController {
		return self
	}
	
	func mediaViewerManager(_ manager: AKMediaViewerManager, mediaURLForView view: UIView) -> URL {
		let defaultFailSafeUrl = URL(string: "http://")!
		return currentMediaUrl ?? defaultFailSafeUrl
	}
	
	func mediaViewerManager(_ manager: AKMediaViewerManager, titleForView view: UIView) -> String {
		return ""
	}
}
