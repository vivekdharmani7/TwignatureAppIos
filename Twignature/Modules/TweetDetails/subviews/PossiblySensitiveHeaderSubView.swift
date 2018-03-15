//
//  PossiblySensitiveTweetSubView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 11/8/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class PossiblySensitiveHeaderSubView: UIView, NibLoadable {

	var changeSettingCallBack: Closure<Void>?
	
	@IBAction func changeSettingDidTap(_ sender: Any) {
		changeSettingCallBack?()
	}
	
}
