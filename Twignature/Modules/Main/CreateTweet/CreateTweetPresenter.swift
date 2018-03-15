//
//  CreateTweetPresenter.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/12/17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import LocationPickerViewController
import Proposer
import ImagePicker
import Photos
import MapKit

class CreateTweetPresenter: NSObject {
	
	private lazy var locationManager = CLLocationManager()
	private lazy var geocoder = CLGeocoder()
	var referenceIdentifier: Identifier?
	fileprivate weak var backgroundImagePicker: ImagePickerController?

	var tweetToRetweet: Tweet? {
		didSet {
			var replyLettersCount = 0
			guard let tweet = tweetToRetweet else {
				return
			}
			let replyToUrl = tweet.shareURL
			replyLettersCount = replyToUrl.characters.count + 2
			maxTweetLength = AppDefined.maxTweetLettersNumber - replyLettersCount
			controller.maxTweetLength = maxTweetLength
		}
	}
	
	var tweetToReply: Tweet? {
		didSet {
			var replyLettersCount = 0
			if let replyToName = tweetToReply?.tweetInfo.user.screenName {
				replyLettersCount = replyToName.count + 2
			}
			maxTweetLength = AppDefined.maxTweetLettersNumber - replyLettersCount
			controller.maxTweetLength = maxTweetLength
		}
	}
	
	private var maxTweetLength: Int = AppDefined.maxTweetLettersNumber
	
    //MARK: - Init
    required init(controller: CreateTweetViewController,
                  interactor: CreateTweetInteractor,
                  coordinator: CreateTweetCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: CreateTweetCoordinator
    fileprivate unowned var controller: CreateTweetViewController
    fileprivate var interactor: CreateTweetInteractor
	fileprivate var pickedLocation: LocationItem?
	fileprivate var attachedImages: [UIImage] = []
	fileprivate var assets: ImageStack?
	fileprivate var withSeal: Bool = false
	var postCreatedHandler: ((Bool) -> Void)?
    
    func didEnter(username: String) {
        interactor.searchUsers(query: username) { [weak self] result in
            self?.controller.endInfiniteScroll()
            switch result {
            case .success(let users):
                self?.controller.reload(matches: users.map { CreateTweetViewController.UserViewModel(user: $0) })
            case .failure(let error):
                self?.controller.showError(error)
            }
        }
    }
    
    func didScrollUsersListToBottom() {
        interactor.loadMoreUsers { [weak self] result in
            self?.controller.endInfiniteScroll()
            switch result {
            case .success(let users):
                self?.controller.append(matches: users.map { CreateTweetViewController.UserViewModel(user: $0) })
            case .failure(let error):
                self?.controller.showError(error)
            }
        }
    }
	
	private func trySelectLocationHelper() {
		guard let location = locationManager.location else {
			return
		}
		
		geocoder.cancelGeocode()
		geocoder.reverseGeocodeLocation(location) { [unowned self] (placemarks, _) in
			guard let placemarks = placemarks, let placemark = placemarks.first else { return }
			let item = MKMapItem(placemark: MKPlacemark(placemark: placemark))
			let pickedLocation = LocationItem(mapItem: item)
			self.pickedLocation = pickedLocation
			self.controller.setupLocationText(pickedLocation.name)
		}
	}
	
	private func trySelectLocation() {
		let locations: PrivateResource = .location(.whenInUse)
		let propose: Propose = {
			proposeToAccess(locations, agreed: { [weak self] in
				self?.trySelectLocationHelper()
				}, rejected: { })
		}
		propose()
	}
	
    func viewIsReady() {
		trySelectLocation()
		showLandscapeAlertIfNeeded()

        controller.configure(avatarUrl: Session.current?.user.profileImageUrl)
		interactor.updateCurrentUserInfo() { [weak self] result in
			switch result {
			case .success(let user):
				guard let seal = user.seal,
					let sealUrl = URL(string: "\(NetworkService.environment.imagesUrl)\(seal.imagePath)") else {
					return
				}
				Session.current?.updateSessionWithTempUser(user)
				self?.controller.updateSealWithUrl(sealUrl)
			case .failure(let error):
				self?.controller.showError(error)
			}
		}
		
		if let replyToName = tweetToReply?.tweetInfo.user.screenName {
			controller.replyToText = "in reply to @\(replyToName)"
		} else {
			controller.replyToText = nil
		}

	    didChangePurchaseStatus()
	    let notificationName = NSNotification.Name(Key.isPowerPanPurchasedKey)
	    NotificationCenter.default.addObserver(self, selector: #selector(didChangePurchaseStatus), name: notificationName , object: nil)
    }

	@objc
	private func didChangePurchaseStatus() {
		self.controller.setFull(UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey))
	}


	func didPressCreateTweet(text: String) {
        guard text.count <= maxTweetLength else {
			controller.showError(TwignatureError.maximumCharactersLimit)
			return
		}
		//configure media
		var mediaPhotos = attachedImages
		if let signature = controller.getSignature() {
			mediaPhotos.append(signature)
		}

		let media = mediaPhotos.isEmpty ? nil: Media.photos(mediaPhotos)
		//configure location
		var location: Location?
		if let coordinates = pickedLocation?.coordinate {
			location = Location(coordinates.latitude, coordinates.longitude)
		}
		//send tweet
		let attachedTweet = tweetToReply ?? tweetToRetweet
		let role: AttachmentTweetRole = self.tweetToRetweet != nil ? .retweet : .reply
		controller.showHUD(withText: R.string.tweets.tweetCreating())
		interactor.createTweet(text: text,
		                       location: location,
		                       media: media,
		                       attachedTweet: attachedTweet,
		                       withRole: role,
		                       withSeal: self.withSeal,
		                       andReference: self.referenceIdentifier) { [weak self] result in
            switch result {
            case .success:
				self?.controller.hideHUD()
				self?.postCreatedHandler?(true)
                self?.controller.showSuccess(with: R.string.tweets.tweetSuccessfullyCreated())
				self?.coordinator.dismiss()
            case .failure(let error):
				self?.controller.hideHUD()
                self?.controller.showError(error)
            }
		}
    }
    
    func finishSearch() {
        interactor.finishSearch()
    }
	
	//need to pick place
	func actionForSelectedLocation() {
		let locations: PrivateResource = .location(.whenInUse)
		let propose: Propose = {
			proposeToAccess(locations, agreed: { [weak self] in
				self?.showLocationPicker()
			}, rejected: { [weak self] in
				self?.controller.showError(TwignatureError.accessDenied)
			})
		}
		propose()
	}
	
	func actionForSealButton() {
		let createdAt = Date()
		guard let user = Session.current?.user,
			let seal = user.seal,
			let image = controller.getSignature(),
			let signId = referenceIdentifier?.id else {
				return
		}
		
		let detailsViewModel = SealDetailsViewModel(withSeal: seal,
		                                            user: user,
		                                            withSignatureImage: image,
		                                            createdAt: createdAt,
		                                            withSignId: signId,
		                                            locationFullName: pickedLocation?.formattedAddressString)
		coordinator.displaySealDetails(withViewModel: detailsViewModel)
	}
	
	fileprivate func showLocationPicker() {
		let locationPicker = LocationPicker()
		locationPicker.searchBar.text = self.pickedLocation?.name ?? ""
		if let pickedLocation = self.pickedLocation {
			locationPicker.alternativeLocations = [pickedLocation]
		}
		locationPicker.searchTextChanged = { _ in
			locationPicker.alternativeLocations = []
		}
		locationPicker.pickCompletion = { [weak self] pickedLocationItem in
			// Do something with the location the user picked.
			self?.pickedLocation = pickedLocationItem
			self?.controller.setupLocationText(pickedLocationItem.name)
		}
		locationPicker.middleButtonHandler = { [weak self] sender in
			self?.pickedLocation = nil
			self?.controller.setupLocationText("")
			sender.dismiss(animated: true, completion: nil)
			
		}
		_ = locationPicker.view
		locationPicker.addBarButtons()
		locationPicker.addMiddleButton(withTitle: "Clear location")
		let navigationController = BaseNavigationController(rootViewController: locationPicker)
		controller.present(navigationController, animated: true, completion: nil)
	}
	
	func actionForImagePicker() {
		let imagePicker = ImagePickerController()
		if let stack = assets {
			imagePicker.stack = stack
			imagePicker.galleryView.selectedStack = stack
		}
		imagePicker.imageLimit = 3
		imagePicker.delegate = self
		controller.present(imagePicker, animated: true) { [weak self] in
			let notification = Notification.Name(rawValue: ImageStack.Notifications.stackDidReload)
			NotificationCenter.default.post(name: notification, object: self?.assets, userInfo: nil)
		}
	}

	func actionForBackgroundImagePicker() {
		let imagePicker = ImagePickerController()
		imagePicker.imageLimit = 1
		imagePicker.delegate = self
		controller.present(imagePicker, animated: true)
		self.backgroundImagePicker = imagePicker
	}
	
	func numberOfAttachments() -> Int {
		return attachedImages.count
	}
	
	func attachmentForIndex(_ index: Int) -> UIImage? {
		guard index < attachedImages.count else {
			return nil
		}
		return attachedImages[index]
	}
	
	func backState() {
		withSeal = false
	}
	
	func backAction() {
		coordinator.dismiss()
	}
	
	func didPressPostOnEditingScreen() {
		guard let isVerified = Session.current?.user.isVerified,
			isVerified,
			TouchIdValidator.isTouchIdAvailable() else {
			controller.showPreview(withSeal: false)
			return
		}
		let alert = UIAlertController(title: nil,
				message: "\n\n\nAuthenticate this original signature as certified?",
				preferredStyle: .alert)
		let frame = CGRect(x: 270 / 2 - 20, y: 20, width: 40, height: 40)
		let touchIdImageView = UIImageView(frame: frame)
		
		touchIdImageView.image = #imageLiteral(resourceName: "touchBlack")
		touchIdImageView.tintColor = .red
		alert.view.addSubview(touchIdImageView)
		let verifiedUserAction = UIAlertAction(title: R.string.tweets.tweetPostAsVerifiedUser(),
		                                       style: .default) { [unowned self] _ in
												guard self.controller.getSignature() != nil else {
													self.controller.showError(TwignatureError.signatureNotAttached)
													return
												}
												
												self.didRequestVerification()
		}
		let nonVerifiedUserAction = UIAlertAction(title: R.string.tweets.tweetPostAsNonVeridiedUser(),
		                                          style: .default) { [weak self] _ in
													self?.controller.showPreview(withSeal: false)
		}
		let cancelAction = UIAlertAction(title: R.string.tweets.cancel(),
		                                 style: .cancel) { [weak self] _ in
			self?.controller.setSignatureDrawedState(CreateTweetViewController.TweetDrawState.notDrawed)
		}
		alert.addAction(verifiedUserAction)
		alert.addAction(nonVerifiedUserAction)
		alert.addAction(cancelAction)
		controller.present(alert, animated: true, completion: nil)
	}
	
	private func showLandscapeAlertIfNeeded() {
		guard !UserDefaults.standard.bool(forKey: Key.landscapeTipPressented) else {
			return
		}
		
		let alertWidth: CGFloat = 270
		
		let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
		let regularFont = R.font.sfuiTextLight(size: 17)!
		let boldfont = UIFont.systemFont(ofSize: 13, weight: UIFontWeightMedium)
		let attr1 = [ NSFontAttributeName : regularFont ]
		let attr2 = [ NSFontAttributeName : boldfont ]
		let strLine1 = NSAttributedString(string:  "\n\n\n" + "Landscape mode available", attributes: attr1)
		let strLine2 = NSAttributedString(string: "\n\n" + "Use landscape mode for better drawing", attributes: attr2)
		let attributedTitle = NSMutableAttributedString(attributedString: strLine1)
		attributedTitle.append(strLine2)
		
		let cancelAction = UIAlertAction(title: "Got It",
		                                 style: .cancel) { _ in
			UserDefaults.standard.set(true, forKey: Key.landscapeTipPressented)
			UserDefaults.standard.synchronize()
		}

		alert.addAction(cancelAction)
		alert.setValue(attributedTitle, forKey: "attributedTitle")
		controller.present(alert, animated: true, completion: nil)
		
		let touchIdImageView = UIImageView(frame: CGRect(x: alertWidth * 0.5 - 20, y: 20, width:40, height:40))
		touchIdImageView.image = #imageLiteral(resourceName: "landscape_icon")
		alert.view.subviews.first?.subviews.first?.addSubview(touchIdImageView)
	}
	
    func didRequestVerification() {
        interactor.authenticateUser { [unowned self] result in
            switch result {
            case .success:
				self.requestTweetReference()
            case .failure(let error):
                self.controller.showError(error)
            }
        }
    }
	
	func requestTweetReference() {
		controller.showHUD()
		interactor.createTwignatureReference { [weak self] (result) in
			switch result {
			case .success(let reference):
				self?.withSeal = true
				self?.controller.showPreview(withSeal: true)
				self?.referenceIdentifier = reference
				self?.controller.hideHUD()
			case .failure(let error):
				self?.withSeal = false
				self?.controller.showPreview(withSeal: false)
				self?.controller.hideHUD()
				self?.controller.showError(error)
			}
		}
	}

	func actionForColorsButtonPress() {
		if UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey) {
			coordinator.showBrushSettings(withDelegate: self, selectedColor: self.controller.brushVal.color, andSelectedSize: self.controller.brushVal.width)
		} else {
			coordinator.showPurchasePopup()
		}
	}

	func actionForBackgroundImageButtonPress() {
		if UserDefaults.standard.bool(forKey: Key.isPowerPanPurchasedKey) {
			self.actionForBackgroundImagePicker()
		} else {
			coordinator.showPurchasePopup()
		}
	}
}

extension CreateTweetPresenter: BrushSettingsDelegate {

	func didSelectColor(_ color: UIColor) {
		self.controller.brushVal.color = color
	}

	func didSelectBrushSize(_ size: CGFloat) {
		self.controller.brushVal.width = size
	}

}

extension CreateTweetPresenter: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
			return
		}
		attachedImages.append(image)
		controller.reloadAttachments()
	}
}

extension CreateTweetPresenter: ImagePickerDelegate {
	
	func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
		
	}
	
	func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
		imagePicker.dismiss(animated: true, completion: nil)
		if imagePicker == self.backgroundImagePicker {
			guard let image = images.first else {
				return
			}
			self.controller.updateBackgroundImage(image)
		} else {
			imagePicker.dismiss(animated: true, completion: nil)
			assets = imagePicker.galleryView.selectedStack
			attachedImages = images
			controller.reloadAttachments()
		}
	}
	
	func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
		imagePicker.dismiss(animated: true, completion: nil)
		if imagePicker != self.backgroundImagePicker {
			assets = imagePicker.galleryView.selectedStack
			attachedImages = []
			controller.reloadAttachments()
		}
	}
}
