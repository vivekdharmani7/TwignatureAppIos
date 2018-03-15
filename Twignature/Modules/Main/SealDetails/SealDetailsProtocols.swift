//
//  SealDetailsProtocols.swift
//  Twignature
//
//  Created by mac on 04.10.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol SealDetailsCoordinator: BaseCoordinator, CanShowSealDetails {
	func displaySealDetails(_ tweetViewModel: FeedViewModel.TweetViewItem)
}
