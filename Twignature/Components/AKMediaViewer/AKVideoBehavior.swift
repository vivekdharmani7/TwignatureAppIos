//
//  AKVideoBehavior.swift
//  AKMediaViewer
//
//  Created by Diogo Autilio on 3/22/16.
//  Copyright © 2016 AnyKey Entertainment. All rights reserved.
//

import Foundation
import UIKit

public class AKVideoBehavior: NSObject {

    public func addVideoIconToView(_ view: UIView, image: UIImage?) {

        var videoIcon: UIImage? = image

        if (videoIcon == nil) || videoIcon!.size.equalTo(CGSize.zero) {
            videoIcon = UIImage(named: "icon_big_play", in: Bundle.AKMediaFrameworkBundle(), compatibleWith: nil)
        }
        let imageView = UIImageView(image: videoIcon)
        imageView.contentMode = .center
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = view.bounds
        view.addSubview(imageView)
    }
}
