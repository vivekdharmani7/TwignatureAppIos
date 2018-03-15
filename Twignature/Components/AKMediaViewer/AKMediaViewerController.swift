//
//  AKMediaViewerController.swift
//  AKMediaViewer
//
//  Created by Diogo Autilio on 3/18/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Player
import EasyPeasy

// MARK: - PlayerView

public class PlayerView: UIView {

    override public class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    func player() -> AVPlayer? {
        guard let avPlayer = (layer as? AVPlayerLayer) else {
            return nil
        }
        return avPlayer.player
    }

    func setPlayer(_ player: AVPlayer?) {
        if let avPlayer = (layer as? AVPlayerLayer) {
            avPlayer.player = player
        }
    }
}

// MARK: - AKMediaViewerController

public class AKMediaViewerController: UIViewController, UIScrollViewDelegate {

    public var tapGesture = UITapGestureRecognizer()
    public var doubleTapGesture = UITapGestureRecognizer()
    public var controlMargin: CGFloat = 0.0
    public var playerView: PlayerView?
    public var imageScrollView = AKImageScrollView()
    public var controlView: AKVideoControlView?

    @IBOutlet var mainImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var accessoryView: UIView!
    @IBOutlet var contentView: UIView!

    var accessoryViewTimer: Timer?
    var player: AVPlayer?
    var activityIndicator: UIActivityIndicatorView?
    var mobilePlayer: Player?

    var observersAdded = false

    struct ObservedValue {
        static let PresentationSize = "presentationSize"
        static let PlayerKeepUp = "playbackLikelyToKeepUp"
        static let PlayerHasEmptyBuffer = "playbackBufferEmpty"
        static let Status = "status"
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(AKMediaViewerController.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        controlMargin = 5.0

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(AKMediaViewerController.handleTap(_:)))
        tapGesture.require(toFail: doubleTapGesture)

        view.addGestureRecognizer(tapGesture)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeObservers(player: self.player)
        player?.removeObserver(self, forKeyPath: ObservedValue.Status)

        mainImageView = nil
        contentView = nil
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.layer.shadowOpacity = 1
        titleLabel.layer.shadowOffset = CGSize.zero
        titleLabel.layer.shadowRadius = 1
        accessoryView.alpha = 0
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers(player: self.player)
    }

    func removeObservers(player: AVPlayer?) {
        if observersAdded {
            guard let item = player?.currentItem else {
                return
            }

            item.removeObserver(self, forKeyPath: ObservedValue.PresentationSize)
            item.removeObserver(self, forKeyPath: ObservedValue.PlayerKeepUp)
            item.removeObserver(self, forKeyPath: ObservedValue.PlayerHasEmptyBuffer)
            observersAdded = false
        }
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override public func beginAppearanceTransition(_ isAppearing: Bool, animated: Bool) {
        if !isAppearing {
            accessoryView.alpha = 0.0
            playerView?.alpha = 0.0
			mobilePlayer?.view.alpha = 0.0
        }
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerView?.frame = mainImageView.bounds
    }

    // MARK: - Public

    public func showPlayerWithURL(_ url: URL) {
        let mobilePlayer = Player()
        mobilePlayer.url = url
        self.addChildViewController(mobilePlayer)
        mobilePlayer.playbackDelegate = self

        mobilePlayer.view.backgroundColor = .clear
        mobilePlayer.view.frame = mainImageView.bounds
        mobilePlayer.view.translatesAutoresizingMaskIntoConstraints = false

        mainImageView.superview?.insertSubview(mobilePlayer.view, aboveSubview: mainImageView)

        mobilePlayer.view.easy.layout(Size().like(mobilePlayer.view.superview!))
        mobilePlayer.view.easy.layout(Top())
        mobilePlayer.view.easy.layout(Leading())

        mobilePlayer.didMove(toParentViewController: self)
        mobilePlayer.playFromBeginning()
        self.mobilePlayer = mobilePlayer

//        self.present(mobilePlayer, animated: true)
//        playerView = PlayerView(frame: mainImageView.bounds)
//        mainImageView.addSubview(self.playerView!)
//        playerView?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
//        playerView?.isHidden = true

        // install loading spinner for remote files
//        if !url.isFileURL {
//            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
//            self.activityIndicator?.frame = UIScreen.main.bounds
//            self.activityIndicator?.hidesWhenStopped = true
//            view.addSubview(self.activityIndicator!)
//            self.activityIndicator?.startAnimating()
//        }
//
//        DispatchQueue.main.async(execute: { () -> Void in
//            // remove old item observer if exists
//            self.removeObservers(player: self.player)
//
//            self.player = AVPlayer(url: url)
//            self.playerView?.setPlayer(self.player)
//            self.player?.currentItem?.addObserver(self, forKeyPath: ObservedValue.PresentationSize, options: .new, context: nil)
//            self.player?.currentItem?.addObserver(self, forKeyPath: ObservedValue.PlayerHasEmptyBuffer, options: .new, context: nil)
//            self.player?.currentItem?.addObserver(self, forKeyPath: ObservedValue.PlayerKeepUp, options: .new, context: nil)
//            self.observersAdded = true
//            self.player?.addObserver(self, forKeyPath: ObservedValue.Status, options: .initial, context: nil)
//            self.layoutControlView()
//        })
    }

    public func didChangePlaybackSliderValue(_ sender: UISlider) {
		guard let maximumDuration = mobilePlayer?.maximumDuration else {
			return
		}
		let time = Double(sender.value * Float(maximumDuration))
        mobilePlayer?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }

    public func playPauseButtonPressed(_ sender: Any) {
		guard let state = self.mobilePlayer?.playbackState else { return }
		switch state {
		case .playing:
				self.mobilePlayer?.pause()
                self.controlView?.playPauseButton.isSelected = false
		case .paused:
				self.mobilePlayer?.playFromCurrentTime()
                self.controlView?.playPauseButton.isSelected = true
		case .stopped:
				self.mobilePlayer?.playFromBeginning()
                self.controlView?.playPauseButton.isSelected = true
		default: break
		}
    }

    public func focusDidEndWithZoomEnabled(_ zoomEnabled: Bool) {
        if zoomEnabled && (playerView == nil) {
            installZoomView()
        }

        view.setNeedsLayout()
        showAccessoryView(true)
        playerView?.isHidden = false

        addAccessoryViewTimer()

        if player?.status == .readyToPlay {
            playPLayer()
        }
    }

    public func defocusWillStart() {
        if playerView == nil {
            uninstallZoomView()
        }
        pinAccessoryView()
        player?.pause()
    }

    // MARK: - Private

    func addAccessoryViewTimer() {
        if player != nil {
            accessoryViewTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(AKMediaViewerController.removeAccessoryViewTimer), userInfo: nil, repeats: false)
        }
    }

    func removeAccessoryViewTimer() {
        accessoryViewTimer?.invalidate()
        showAccessoryView(false)
    }

    func installZoomView() {
        let scrollView = AKImageScrollView(frame: contentView.bounds)
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        scrollView.delegate = self
        imageScrollView = scrollView
        contentView.insertSubview(scrollView, at: 0)
        scrollView.displayImage(mainImageView.image!)
        self.mainImageView.isHidden = true

        imageScrollView.addGestureRecognizer(doubleTapGesture)
    }

    func uninstallZoomView() {
        if let zoomImageViewFrame = imageScrollView.zoomImageView?.frame {
            let frame = contentView.convert(zoomImageViewFrame, from: imageScrollView)
            imageScrollView.isHidden = true
            mainImageView.isHidden = false
            mainImageView.frame = frame
        }
    }

    func isAccessoryViewPinned() -> Bool {
        return (accessoryView.superview == view)
    }

    func pinView(_ view: UIView) {
        let frame = self.view.convert(view.frame, from: view.superview)
        view.transform = view.superview!.transform
        self.view.addSubview(view)
        view.frame = frame
    }

    func pinAccessoryView() {
        // Move the accessory views to the main view in order not to be rotated along with the media.
        pinView(accessoryView)
    }

    func showAccessoryView(_ visible: Bool) {
        if visible == accessoryViewsVisible() {
            return
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.accessoryView.alpha = (visible ? 1.0 : 0.0)
        }, completion: nil)
    }

    func accessoryViewsVisible() -> Bool {
        return (accessoryView.alpha == 1.0)
    }

    func layoutControlView() {

        if isAccessoryViewPinned() {
            return
        }

        if self.controlView == nil {
            if let controlView = AKVideoControlView.videoControlView() {
                controlView.translatesAutoresizingMaskIntoConstraints = false
                self.controlView = controlView
                accessoryView.addSubview(controlView)
                controlView.playPauseButton.addTarget(self, action: #selector(AKMediaViewerController.playPauseButtonPressed(_:)), for: .touchUpInside)
                controlView.slider.addTarget(self, action: #selector(AKMediaViewerController.didChangePlaybackSliderValue(_:)), for: .touchUpInside)
            }
        }

        if var controlViewframe = self.controlView?.frame {
            controlViewframe.size.width = self.view.bounds.size.width - self.controlMargin * 2
            controlViewframe.origin.x = self.controlMargin

			let videoFrame = self.mobilePlayer?.playerLayer()?.videoRect ?? CGRect.zero
            let titleFrame = self.controlView!.superview!.convert(titleLabel.frame, from: titleLabel.superview)
            controlViewframe.origin.y =  titleFrame.origin.y - controlViewframe.size.height - self.controlMargin
            if videoFrame.size.width > 0 {
                controlViewframe.origin.y = min(controlViewframe.origin.y, videoFrame.maxY - controlViewframe.size.height - self.controlMargin)
            }
            self.controlView!.frame = controlViewframe
        }
    }

    func buildVideoFrame() -> CGRect {
        if let playerCurrentItem = self.player?.currentItem, playerCurrentItem.presentationSize.equalTo(CGSize.zero) {
            return .zero
        }

        var frame = AVMakeRect(aspectRatio: self.player!.currentItem!.presentationSize, insideRect: self.playerView!.bounds)
        frame = frame.integral

        return frame
    }

    func playPLayer() {
        activityIndicator?.stopAnimating()
        player?.play()
    }

    // MARK: - Actions

    func handleTap(_ gesture: UITapGestureRecognizer) {
        if imageScrollView.zoomScale == imageScrollView.minimumZoomScale {
            showAccessoryView(!accessoryViewsVisible())
        }
    }

    func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        var frame = CGRect.zero
        var scale = imageScrollView.maximumZoomScale

        if imageScrollView.zoomScale == imageScrollView.minimumZoomScale {
            if let contentView = imageScrollView.delegate?.viewForZooming?(in: imageScrollView) {
                let location = gesture.location(in: contentView)
                frame = CGRect(x: location.x * imageScrollView.maximumZoomScale - imageScrollView.bounds.size.width/2, y: location.y*imageScrollView.maximumZoomScale - imageScrollView.bounds.size.height/2, width: imageScrollView.bounds.size.width, height: imageScrollView.bounds.size.height)
            }
        } else {
            scale = imageScrollView.minimumZoomScale
        }

        UIView.animate(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: { () -> Void in
            self.imageScrollView.zoomScale = scale
            self.imageScrollView.layoutIfNeeded()
            if scale == self.imageScrollView.maximumZoomScale {
                self.imageScrollView.scrollRectToVisible(frame, animated: false)
            }
        }, completion: nil)

    }

    // MARK: - <UIScrollViewDelegate>

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageScrollView.zoomImageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        showAccessoryView(imageScrollView.zoomScale == imageScrollView.minimumZoomScale)
    }

    // MARK: - KVO

    override public func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {

        guard let keyPath = keyPath else {
            return
        }

        switch keyPath {

        case ObservedValue.PlayerKeepUp:
            guard let playerCurrentItem = player?.currentItem else {
                return
            }
            if playerCurrentItem.isPlaybackLikelyToKeepUp && (player?.rate != 0 && player?.error == nil) {
                playPLayer()
            }

        case ObservedValue.Status:
            guard let status = player?.status else {
                return
            }
            switch status {
            case .readyToPlay:
                playPLayer()
            default:
                player?.pause()
                activityIndicator?.startAnimating()
            }

        case ObservedValue.PlayerHasEmptyBuffer:
            activityIndicator?.startAnimating()

        case ObservedValue.PresentationSize:
            view.setNeedsDisplay()

        default:
            break
        }
    }
}

extension AKMediaViewerController: PlayerPlaybackDelegate {
	public func playerCurrentTimeDidChange(_ player: Player) {
        let fraction = Double(player.currentTime) / Double(player.maximumDuration)
		
        if !(self.controlView?.isPicked ?? true) {
			self.controlView?.slider.value = Float(fraction)
            self.controlView?.durationLabel.text = player.maximumDuration.timecodeForTimeInterval()
            self.controlView?.currentTimeLabel.text = player.currentTime.timecodeForTimeInterval()
        }
    }

	public func playerPlaybackWillStartFromBeginning(_ player: Player) {
        layoutControlView()
		self.controlView?.playPauseButton.isSelected = true
    }

	public func playerPlaybackDidEnd(_ player: Player) {
        self.controlView?.playPauseButton.isSelected = false
    }

	public func playerPlaybackWillLoop(_ player: Player) {
    }
}
