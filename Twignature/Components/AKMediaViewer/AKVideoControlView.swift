//
//  AKVideoControlView.swift
//  AKMediaViewer
//
//  Created by Diogo Autilio on 3/18/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class AKVideoControlView: UIView {

    @IBOutlet public var scrubbing: ASBPlayerScrubbing!
    @IBOutlet var slider: UISlider!
    @IBOutlet var remainingTimeLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var currentTimeLabel: UILabel!
    @IBOutlet var playPauseButton: UIButton!

    var isPicked: Bool = false

    override public func awakeFromNib() {
        super.awakeFromNib()
//        scrubbing.addObserver(self, forKeyPath: "player", options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
//        scrubbing.removeObserver(self, forKeyPath: "player")
//        scrubbing.player.removeObserver(self, forKeyPath: "rate")
    }

    class func videoControlView() -> AKVideoControlView? {
        let arrayOfViews = Bundle.AKMediaFrameworkBundle().loadNibNamed("AKVideoControlView", owner: nil, options: nil)
        guard let videoControlView = arrayOfViews?.first as? AKVideoControlView else {
            return nil
        }
        return videoControlView
    }

    // MARK: - IBActions

    @IBAction func switchTimeLabel(_ sender: AnyObject) {
        self.remainingTimeLabel.isHidden = !self.remainingTimeLabel.isHidden
        self.durationLabel.isHidden = !self.remainingTimeLabel.isHidden
    }

    @IBAction func sliderDidPick(_ sender: Any) {
        isPicked = true
    }

    @IBAction func sliderDidEndPicking(_ sender: Any) {
        isPicked = false
    }
    // MARK: - KVO

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "player" {
            if scrubbing.player != nil {
                scrubbing.player.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
            }
        } else {
            if let player = object as? AVPlayer {
                playPauseButton.isSelected = (player.rate != 0)
            }
        }
    }
}
