//
//  SideMenuProtocols.swift
//  Twignature
//
//  Created by mac on 05.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol SideMenuCoordinator: BaseCoordinator {
	func performLogout()
	func showMyProfile()
	func showSettings()
	func showTwignatureFeed()
	func showVerificationRequest()
}
