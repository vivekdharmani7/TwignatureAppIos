//
//  PossiblySensitiveTweetSubView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 11/8/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class PossiblySensitiveTweetSubView: UIView, NibLoadable {
	override var intrinsicContentSize: CGSize {
		return CGSize(width: super.intrinsicContentSize.width, height: 150)
	}
}
