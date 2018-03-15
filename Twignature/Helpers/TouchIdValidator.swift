//
//  TouchIdValidator.swift
//  Twignature
//
//  Created by mac on 03.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIdValidator {
	static func isTouchIdAvailable() -> Bool {
		var error: NSError?
		if #available(iOS 11.2, *) {
			if LAContext().biometryType != .none {
				return true
			}
		}
		return LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
	}
}
