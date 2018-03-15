//
//  AuthorizationFlow.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import UIKit

class AuthorizationFlow {
    
    unowned fileprivate let appFlow: AppFlow
    
    init(appFlow: AppFlow) {
        self.appFlow = appFlow
    }
}

extension AuthorizationFlow: SignInCoordinator {
    func didLogin() {
		guard UserDefaults.standard.bool(forKey: Key.onBoardingPressented) else {
			appFlow.startOnBoardingFlow()
			return
		}
		appFlow.startMainFlow()
    }
}
