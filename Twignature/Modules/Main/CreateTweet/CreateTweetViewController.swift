//
//  CreateTweetViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/12/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField
import IQKeyboardManagerSwift

private let toolBarHeight: CGFloat = 60
private let tableViewRelativeHeight: CGFloat = 100
private let toolbarDistanceToBottom: CGFloat = 375
private let undoRedoContainerWidth: CGFloat = 280

class CreateTweetViewController: BaseViewController {
	
	var maxTweetLength: Int = AppDefined.maxTweetLettersNumber
	var replyToText: String? {
		didSet {
			replyToLabel.text = replyToText
		}
	}
    enum SearchMode {
        case inactive, active, fullScreen, transition
    }
    
    enum TweetCreationStage {
        case creation, preview
    }
	
	enum TweetDrawState {
		case notDrawed, drawing, drawed
	}
    
    struct ViewAttributes {
        let toolbarWidth: CGFloat
        let searchBarAlpha: CGFloat
        let navigationBarAlpha: CGFloat
        let tableViewHeight: CGFloat
		let showCounter: Bool
    }
	
	@IBOutlet fileprivate weak var undoRedoNavBarButtonItem: UIBarButtonItem!
    @IBOutlet fileprivate weak var undoRedoNavBarContainer: UIView!
    @IBOutlet fileprivate weak var toolbar: UIView!
    @IBOutlet fileprivate weak var signatureView: UIView!
	@IBOutlet fileprivate weak var penButton: UIBarButtonItem!
	@IBOutlet fileprivate weak var postButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var undoButton: UIButton!
    @IBOutlet fileprivate weak var redoButton: UIButton!
	@IBOutlet fileprivate weak var undoBarView: UIView!
    @IBOutlet fileprivate weak var textView: JVFloatLabeledTextView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var toolbarBottomConstraint: NSLayoutConstraint!
	@IBOutlet fileprivate weak var toolbarAndTextViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var avatarView: AvatarContainerView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
	@IBOutlet fileprivate weak var locationButton: UIButton!
	@IBOutlet fileprivate weak var imagePickerButton: UIButton!
	@IBOutlet fileprivate weak var sealButton: UIButton!
	@IBOutlet fileprivate weak var attachmentsCollectionView: UICollectionView!
	@IBOutlet fileprivate weak var sealImageView: UIImageView!	
	@IBOutlet fileprivate weak var waterMarkImageView: UIView!
	@IBOutlet fileprivate var previewConstraints: [NSLayoutConstraint]!
    @IBOutlet fileprivate weak var signatureViewTapButton: UIButton!
    @IBOutlet fileprivate weak var drawContextImageView: UIImageView!
	
	@IBOutlet private weak var replyToLabel: UILabel!
	//MARK: - Properties
    var presenter:  CreateTweetPresenter!

    weak var canvasView: Canvas? = nil
    let brushVal = Brush()
    private var dashedBorder: CAShapeLayer!
    fileprivate var infiniteScroll: InfiniteScroll!
    fileprivate var keyboardObserver: KeyboardObserver!
    fileprivate var previousSignature: UIImage?
    fileprivate(set) var currentSignature: UIImage?
    fileprivate var users: [UserViewModel] = []
    fileprivate var hashtags: [String] = []
    fileprivate var userNameRange: NSRange?
    fileprivate var keyboardHeight: CGFloat = 0
    fileprivate var minTableViewHeight: CGFloat { return keyboardHeight + toolBarHeight + tableViewRelativeHeight }
    fileprivate var maxTableViewHeight: CGFloat { return view.bounds.height - Layout.navigationBarHeight }
    fileprivate var searchMode: SearchMode = .inactive
	fileprivate var withSeal: Bool = true
	fileprivate var signatureDrawed: TweetDrawState = TweetDrawState.notDrawed
	fileprivate var isFull: Bool = false

    var creationStage: TweetCreationStage = .creation {
        willSet {
			if newValue == .creation {
				withSeal = true
				signatureDrawed = .notDrawed
			}
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            signatureView.isUserInteractionEnabled = newValue == .creation
            let isHidden = newValue == .preview
			sealImageView.isHidden = !(isHidden && withSeal)
			waterMarkImageView.isHidden = (newValue != .preview) || withSeal
			sealButton.isHidden = sealImageView.isHidden
            dashedBorder.isHidden = isHidden
            undoButton.isHidden = isHidden
            redoButton.isHidden = isHidden
            undoBarView.isHidden = isHidden
			sealButton.isUserInteractionEnabled = isHidden
            signatureViewTapButton.isUserInteractionEnabled = isHidden
			for constraint in previewConstraints {
				constraint.priority = newValue == .preview ? 850: 250
			}
        }
    }
	
	private var kbManagerInitialState = false {
		didSet {
			debugPrint("kbManagerInitialState \(kbManagerInitialState)")
		}
	}
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if creationStage == .creation, UIDevice.current.userInterfaceIdiom != .pad {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
		return UIInterfaceOrientationMask.portrait
	}
	
    //MARK: - Life cycle
    
    deinit {
        infiniteScroll.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureInterface()
        configureKeyboardObservers()
        presenter.viewIsReady()
		view.setNeedsLayout()
		view.layoutIfNeeded()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		kbManagerInitialState = IQKeyboardManager.sharedManager().enable
		IQKeyboardManager.sharedManager().enable = false
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		IQKeyboardManager.sharedManager().enable = kbManagerInitialState
	}
	
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dashedBorder.path = UIBezierPath(roundedRect: signatureView.bounds,
                                         cornerRadius: signatureView.cornerRadius).cgPath
    }
    
    //MARK: - Public
	func setFull(_ isFull: Bool) {
		self.isFull = isFull
		self.brushVal.isWidthDynamic = isFull
	}

	func getSignature() -> UIImage? {
		guard canvasView?.canUndo() ?? false else {
			return nil
		}
		return self.view.snapshot(of: self.signatureView.convert(self.signatureView.bounds, to: self.view))
	}
	
	fileprivate var landscapeImageBeforeRotate: UIImage?
    fileprivate var portraitImageBeforeRotate: UIImage? {
        willSet {
            print("setted")
        }
    }
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		let isLandscape = size.width > size.height
        let isDifferentToPrevious = isLandscape != (view.frame.width > view.frame.height)
		let signatureImage = drawContextImageView.image ?? UIImage()
		let transitionWidth: CGFloat = size.width - 40
		let xibHeight: CGFloat = 290
		let transitionHeight: CGFloat = isLandscape ? xibHeight : xibHeight
		let imageTransitionSize = CGSize(width: transitionWidth, height: transitionHeight)
		var prevImage: UIImage?
        if isDifferentToPrevious {
            if isLandscape {
                prevImage = landscapeImageBeforeRotate
                portraitImageBeforeRotate = signatureImage
                updateNavigationBar(for: .landscapeLeft)
            } else {
                prevImage = portraitImageBeforeRotate
                landscapeImageBeforeRotate = signatureImage
                updateNavigationBar(for: .portrait)
            }
        }
	}
	
	override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
//		configureSignatureViewController(image: currentSignature)
		updateNavigationBar(for: toInterfaceOrientation)
		updateView(for: .inactive)
		view.endEditing(true)
	}
	
	private func imageFitToCanvas(canvasSize: CGSize, image: UIImage) -> UIImage? {
		let aspect = image.size.width / image.size.height
		var topWith:CGFloat
		var topHeight:CGFloat
		if canvasSize.width > canvasSize.height {
			topHeight = canvasSize.height
			topWith = topHeight * aspect
		} else {
			topWith = canvasSize.width
			topHeight = topWith / aspect
		}
		
		if topHeight > canvasSize.height {
			topHeight = canvasSize.height
			topWith = topHeight * aspect
		}
		if topWith > canvasSize.width {
			topWith = canvasSize.width
			topHeight = topWith / aspect
		}
		
		let topSize = CGSize(width: topWith, height: topHeight)
		
		UIGraphicsBeginImageContext(canvasSize)
		
		let x = (canvasSize.width - topSize.width) * 0.5
		let y = (canvasSize.height - topSize.height) * 0.5
		let topAreaSize = CGRect(x: x, y: y, width: topSize.width, height: topSize.height)
		image.draw(in: topAreaSize, blendMode: .normal, alpha: 1.0)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	func updateSealWithUrl(_ url: URL?) {
		sealImageView.kf.setImage(with: url)
	}
	
    func configure(avatarUrl url: URL?) {
        avatarView.imageView.setImage(with: url)
    }
    
    func reload(matches: [UserViewModel]) {
        users = matches
        tableView.reloadData()
    }
    
    func append(matches: [UserViewModel]) {
        let indexPaths = matches.enumerated().map { IndexPath(row: $0.offset + users.count, section: 0) }
        users += matches
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .bottom)
        tableView.endUpdates()
    }
	
	func setupLocationText(_ text: String) {
		locationButton.setTitle(text, for: .normal)
		locationButton.setNeedsLayout()
		updatePostButton()
	}
	
	func reloadAttachments() {
		attachmentsCollectionView.reloadData()
	}
    
    func endInfiniteScroll() {
        infiniteScroll.end()
    }
    
	func showPreview(withSeal: Bool) {
		self.withSeal = withSeal
        creationStage = .preview
    }
	
	func setSignatureDrawedState(_ drawed: TweetDrawState) {
		self.signatureDrawed = drawed
	}
	
	func actionForDrawedSignature() {
		if self.signatureDrawed == .drawing {
			presenter.didPressPostOnEditingScreen()
			self.signatureDrawed = .drawed
		}
	}

	func updateBackgroundImage(_ image: UIImage) {
		self.canvasView?.update(image)
	}
    //MARK: - UI
    
    private func configureInterface() {
        localizeViews()
        updateUndoRedoButtons()
        configureSignatureViewController()
        configureSignatureDashedBorder()
        configureTableView()
        configureSearchBar()
        updateNavigationBar(for: UIApplication.shared.statusBarOrientation)
        textView.delegate = self
		penButton.isEnabled = false
		undoManager?.removeAllActions()
		textView.placeholder = R.string.tweets.tweetPlaceholder()
        textView.text = "#Signrs"
        updateTextView(textView: textView)
        updateSymbolsCountLabel(textView.text.characters.count)
        toolbar.borderColor = Color.lightGray
		attachmentsCollectionView.register(R.nib.mediaItemCell)
		waterMarkImageView.isHidden = true
		sealButton.isHidden = true
    }
    
    private func configureSearchBar() {
        searchBar.showsCancelButton = true
        searchBar.delegate = self
    }
    
    private func configureTableView() {
        tableView.tableFooterView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.borderColor = Color.lightGray
        tableView.register(R.nib.userCell)
        tableView.tableFooterView = UIView()
        infiniteScroll = InfiniteScroll(tableView: tableView)
        infiniteScroll.action = { [unowned self] in
            self.presenter.didScrollUsersListToBottom()
        }
    }
    
    private func localizeViews() {
    }
	
	fileprivate func updatePostButton() {
		let textConstraint = textView.text.isEmpty
		let locationConstraint = locationButton.titleLabel?.text?.isEmpty ?? true
		let imagePickerConstraint = presenter.numberOfAttachments() <= 0
		let signatureConstraint = !(canvasView?.canUndo() ?? false)
		postButton.isEnabled = !(textConstraint && locationConstraint && imagePickerConstraint && signatureConstraint)
	}
    
    fileprivate func updateNavigationBar(for orientation: UIInterfaceOrientation) {
        let bounds = undoRedoNavBarContainer.frame
        switch orientation {
        case .landscapeLeft, .landscapeRight:
            undoRedoNavBarContainer.frame = CGRect(x: bounds.minX, y: bounds.minY,
                                                   width: undoRedoContainerWidth, height: bounds.height)
			undoRedoNavBarButtonItem.width = undoRedoContainerWidth
			penButton.isEnabled = false
			undoRedoNavBarButtonItem.isEnabled = true
			undoRedoNavBarContainer.isHidden = false
			penButton.width = 0
			
        default:
            undoRedoNavBarContainer.frame = CGRect(x: bounds.minX, y: bounds.minY,
                                                   width: 0, height: bounds.height)
			undoRedoNavBarButtonItem.width = 0
			undoRedoNavBarButtonItem.isEnabled = false
			undoRedoNavBarContainer.isHidden = true
			penButton.isEnabled = true
			penButton.width = bounds.height
        }
    }
    
    fileprivate func configureSignatureViewController(image: UIImage? = nil) {
        let canvas = Canvas()
        self.signatureView.addSubview(canvas)
        canvas.pinToSuperview()
        canvas.delegate = self
	    self.signatureView.clipsToBounds = true
	    let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleFingerTap))
	    gesture.numberOfTouchesRequired = 2
	    canvas.addGestureRecognizer(gesture)
        self.canvasView = canvas

    }

	@objc
	fileprivate func doubleFingerTap(_ gesture: UITapGestureRecognizer) {
		if self.isFull {
			self.canvasView?.backgroundImageView.image = UIImage(color: self.brushVal.color)
		}
	}
    
    fileprivate func updateUndoRedoButtons() {
        undoButton.isEnabled = canvasView?.canUndo() ?? false
        redoButton.isEnabled = canvasView?.canRedo() ?? false
		updatePostButton()
    }
    
    private func configureSignatureDashedBorder() {
        dashedBorder = CAShapeLayer()
        dashedBorder.strokeColor = Color.lightGray.cgColor
        dashedBorder.lineDashPattern = [6, 6]
        dashedBorder.lineWidth = 3
        dashedBorder.frame = signatureView.bounds
        dashedBorder.fillColor = nil
        signatureView.layer.addSublayer(dashedBorder)
    }
    
    fileprivate func updateView(for mode: SearchMode, animated: Bool = true) {
        guard searchMode != mode else { return }
        let navBar = navigationController?.navigationBar
        searchBar.isHidden = false
        navBar?.isHidden = false
        switch mode {
        case .active:
            let attrs = ViewAttributes(toolbarWidth: 1,
                                       searchBarAlpha: 0,
                                       navigationBarAlpha: 1,
                                       tableViewHeight: minTableViewHeight,
                                       showCounter: true)
            updateView(attrs: attrs, animated: animated) {
                self.searchMode = mode
                self.setSearchBarAndNavBarHideStatus(for: mode)
            }
        case .fullScreen:
            let attrs = ViewAttributes(toolbarWidth: 1,
                                       searchBarAlpha: 1,
                                       navigationBarAlpha: 0,
                                       tableViewHeight: maxTableViewHeight,
                                       showCounter: false)
            updateView(attrs: attrs, animated: animated) {
                self.searchMode = mode
                self.setSearchBarAndNavBarHideStatus(for: mode)
                self.searchBar.becomeFirstResponder()
            }
        case .inactive:
            let attrs = ViewAttributes(toolbarWidth: 0,
                                       searchBarAlpha: 0,
                                       navigationBarAlpha: 1,
                                       tableViewHeight: 0,
                                       showCounter: true)
            updateView(attrs: attrs, animated: animated) {
                self.searchMode = mode
                self.setSearchBarAndNavBarHideStatus(for: mode)
                self.resetSearch()
            }
        default:
            searchMode = mode
        }
    }
    
    fileprivate func setSearchBarAndNavBarHideStatus(for mode: SearchMode) {
        searchBar.isHidden = !(mode == .fullScreen || mode == .transition)
        navigationController?.navigationBar.isHidden = mode == .fullScreen
    }
    
    fileprivate func updateView(attrs: ViewAttributes, animated: Bool, completion: Closure<Void>? = nil) {
        let updateBlock = {
            self.toolbar.borderWidth = attrs.toolbarWidth
            self.searchBar.alpha = attrs.searchBarAlpha
            self.navigationController?.navigationBar.alpha = attrs.navigationBarAlpha
            self.tableViewHeight.constant = attrs.tableViewHeight
            self.view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: { 
                updateBlock()
            }, completion: { _ in
                completion?()
            })
        } else {
            updateBlock()
            completion?()
        }
    }

    fileprivate func transitToSearchBar(value: CGFloat) {
        guard value >= 0 && value <= 1,
            let navigationBar = navigationController?.navigationBar else { return }
        searchBar.alpha = value
        navigationBar.alpha = (1 - value)
    }
	
	func updateSymbolsCountLabel(_ symbolsCount: Int) {
		guard symbolsCount > 0 else {
			textView.placeholder = R.string.tweets.tweetPlaceholder()
			return
		}
		textView.placeholder = "\(symbolsCount)/\(maxTweetLength)"
	}
	
    //MARK: - Private
    
    fileprivate func resetSearch() {
        presenter.finishSearch()
        self.users = []
        tableView.reloadData()
    }
    
    private func configureKeyboardObservers() {
        keyboardObserver = KeyboardObserver(
                                    onReveal: { [weak self] (height, animationDuration) in
                                        guard let strongSelf = self else { return }
										strongSelf.penButton.isEnabled = true
                                        strongSelf.keyboardHeight = height
                                        strongSelf.tableView.contentInset.bottom = strongSelf.keyboardHeight + toolBarHeight
										self?.toolbarBottomConstraint.constant = height
										self?.toolbarBottomConstraint.priority = 860
										self?.toolbarAndTextViewBottomConstraint.priority = 860
                                        UIView.animate(withDuration: animationDuration) {
                                            strongSelf.view.layoutIfNeeded()
                                        }
                                    },
                                    onCollapse: { [weak self] (_, animationDuration) in
										guard let strongSelf = self else { return }
                                        strongSelf.penButton.isEnabled = false
                                        strongSelf.toolbarBottomConstraint.constant = 0
                                        strongSelf.toolbarBottomConstraint.priority = 200
                                        strongSelf.toolbarAndTextViewBottomConstraint.priority = 750
                                        UIView.animate(withDuration: animationDuration) {
                                            strongSelf.tableViewHeight.constant = 0
                                            strongSelf.view.layoutIfNeeded()
                                        }
                                    })
    }
    
    // MARK: - IBActions
    
    @IBAction fileprivate func signatureViewTapped() {
        creationStage = .creation
    }
    
    @IBAction fileprivate func backDidClick() {
        switch creationStage {
        case .creation:
            presenter.backAction()
        case .preview:
			presenter.backState()
            creationStage = .creation
        }
    }
	
	@IBAction fileprivate func didPressPencilButton(_ sender: Any) {
		view.endEditing(true)
		updateView(for: .inactive)
	}
	
    @IBAction fileprivate func didPressLocation(_ sender: Any) {
        updateView(for: .inactive)
		actionForDrawedSignature()
		presenter.actionForSelectedLocation()
    }
    
    @IBAction fileprivate func didPressGallery(_ sender: Any) {
		actionForDrawedSignature()
		presenter.actionForImagePicker()
    }

    @IBAction func didPressUndo(_ sender: Any) {
        canvasView?.undo()
    }
    
    @IBAction func didPressRedo(_ sender: Any) {
        canvasView?.redo()
    }
    
    @IBAction func didPressCreateTweet(_ sender: UIBarButtonItem) {
        switch creationStage {
        case .creation:
			actionForDrawedSignature()
            presenter.didPressPostOnEditingScreen()
        case .preview:
            view.endEditing(true)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            sender.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { [weak self, weak sender] in
                sender?.isEnabled = true
                guard let strongSelf = self else { return }
                strongSelf.presenter.didPressCreateTweet(text: strongSelf.textView.text)
            })
        }
    }
	
	@IBAction func sealButtonDidPress(_ sender: Any) {
		presenter.actionForSealButton()
	}
    
    @IBAction func swipeDown(_ sender: Any) {
        view.endEditing(true)
        updateView(for: .inactive)
    }

    @IBAction func colorPickerAction(_ sender: Any) {
        presenter.actionForColorsButtonPress()
    }

	@IBAction private func didPressBackgroundImage(_ sender: Any) {
		presenter.actionForBackgroundImageButtonPress()
	}

	fileprivate dynamic func set(signature: UIImage?) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(set(signature:)), object: previousSignature)
        updateUndoRedoButtons()
        if currentSignature != signature {
//            configureSignatureViewController(image: signature)
        }
        previousSignature = signature
		updatePostButton()
		self.signatureDrawed = .drawing
		landscapeImageBeforeRotate = nil
		portraitImageBeforeRotate = nil
    }
}

// MARK: - UITextViewDelegate

extension CreateTweetViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard searchMode == .inactive || searchMode == .active else { return false }
        let total = (textView.text as NSString).replacingCharacters(in: range, with: text)
		if text != ""{
			guard total.characters.count <= maxTweetLength else { return false }
		}
		updateSymbolsCountLabel(total.characters.count)
        let cursor = range.location - range.length
		if let (range, userName) = total.findUser(at: cursor) { //, text != "" {
            let trimmed = userName.trimmingCharacters(in: CharacterSet(charactersIn: "@"))
            userNameRange = range
            updateView(for: .active)
            presenter.didEnter(username: trimmed)
        } else {
            userNameRange = nil
            updateView(for: .inactive)
        }
        return true
    }
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		actionForDrawedSignature()
	}
	
    func textViewDidChange(_ textView: UITextView) {
		updatePostButton()
        updateTextView(textView: textView)
    }

    fileprivate func updateTextView(textView: UITextView) {
        let hashtags = textView.text.findHashtags().map { $0.range }
        let users = textView.text.findUsers().map { $0.range }
        let cursor = textView.selectedRange
        textView.attributedText = textView.text.attributed
            .font(Font.default(size: 15))
            .color(Color.twitterBlue, ranges: hashtags + users)
        textView.selectedRange = cursor
    }
}

// MARK: - UITableViewDataSource

extension CreateTweetViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.userCell.identifier) as? UserCell else {
			return UITableViewCell()
		}
        let user = users[indexPath.row]
        cell.hidesButton = true
        cell.avatarView.imageView.setImage(with: user.avatarUrl)
        cell.nameLabel.text = user.name
        cell.screenNameLabel.text = user.screenName
        if user.isVerified {
            cell.screenNameLabel.add(image: #imageLiteral(resourceName: "ic_verified"))
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CreateTweetViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let range = userNameRange else { return }
        let username = "@\(users[indexPath.row].screenName) "
        textView.text.replaceString(in: range, with: username)
		updateSymbolsCountLabel(textView.text.characters.count)
        textView.becomeFirstResponder()
        updateView(for: .inactive)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchMode == .transition || searchMode == .active else { return }
        let isScrollingDown = scrollView.contentOffset.y < 0
        let isScrollingUp = scrollView.contentOffset.y > 0
        let minHeight = minTableViewHeight
        let maxHeight = maxTableViewHeight
        var newHeight: CGFloat = tableViewHeight.constant
        if isScrollingDown {
            newHeight = max(minHeight, tableViewHeight.constant - abs(scrollView.contentOffset.y))
        } else if isScrollingUp {
            newHeight = min(maxHeight, tableViewHeight.constant + abs(scrollView.contentOffset.y))
        }
        if newHeight != tableViewHeight.constant {
            tableViewHeight.constant = newHeight
            tableView.set(scrollPosition: 0)
            let range = maxTableViewHeight - minTableViewHeight
            let value = ((tableViewHeight.constant - minTableViewHeight) / range)
            updateView(for: .transition)
            transitToSearchBar(value: value)
        } else if newHeight == maxTableViewHeight {
            updateView(for: .fullScreen, animated: false)
        } else if newHeight == minTableViewHeight {
            updateView(for: .active, animated: false)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard searchMode == .transition else { return }
        hideOrRevealSearchBar()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard searchMode == .transition else { return }
        guard !decelerate else { return }
        hideOrRevealSearchBar()
    }
    
    private func hideOrRevealSearchBar() {
        let range = maxTableViewHeight - minTableViewHeight
        let shouldCollapseTableView = ((tableViewHeight.constant - minTableViewHeight) / range).rounded() == 0
        let mode: SearchMode = shouldCollapseTableView ? .active : .fullScreen
        updateView(for: mode)
    }
}

extension CreateTweetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		updatePostButton()
		return presenter.numberOfAttachments()
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.nib.mediaItemCell.identifier, for: indexPath)
		guard let reuseCell = cell as? MediaItemCell else {
			return UICollectionViewCell()
		}
		let model = presenter.attachmentForIndex(indexPath.item)
		reuseCell.imageView.image = model
		return reuseCell
	}
}

//MARK: - UISearchBarDelegate

extension CreateTweetViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            resetSearch()
            return
        }
        presenter.didEnter(username: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        updateView(for: .inactive)
        view.endEditing(true)
    }
}

extension CreateTweetViewController: CanvasDelegate {

    func brush(forTouch touch: UITouch?) -> Brush? {
//        if let touch = touch {
//            if touch.force > 0 {
//                //TODO: play with alpha
//                let percentage = (1 - touch.force)
////                self.brushVal.alpha = percentage
//                self.brushVal.color = UIColor(red: percentage,
//                                              green: percentage,
//                                              blue: percentage,
//                                              alpha: 1)
//            } else {
//                self.brushVal.color = .black
//            }
//            if #available(iOS 9.1, *) {
//                self.brushVal.width = (touch.altitudeAngle / (CGFloat.pi/2)) * 5
//            } else {
//                self.brushVal.width = 5
//            }
//
//        }
        return self.brushVal
    }

    func canvas(_ canvas: Canvas, didUpdateDrawing drawing: Drawing, mergedImage image: UIImage?) {
        signatureDrawed = .drawing
        updateUndoRedoButtons()
    }

    func canvas(_ canvas: Canvas, didSaveDrawing drawing: Drawing, mergedImage image: UIImage?) {
    }
}
