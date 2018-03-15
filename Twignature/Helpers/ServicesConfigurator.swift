//
//  ServicesConfigurator.swift
//  PledgeFit
//
//  Created by Ivan Hahanov on 7/31/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import TwitterKit
import Fabric
import Crashlytics
import KVNProgress

class ServicesConfigurator {
    
    static let SettingsIsProductionEnabledKey = "enabled_production"
    
    static func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        AppearenceHelper.configureAppearence()
        Twitter.sharedInstance().start(withConsumerKey:"PsoYoXQ7mPSdlT54KtegfJZoZ",
                                       consumerSecret:"GJ2RcsQno6F8aEHdHZDvYu318h9SjYUsT6fp6IeCcuNLYJMvp2")
        Fabric.with([Crashlytics.self, Twitter.self])
        let kvnConfig = KVNProgressConfiguration.default()
        kvnConfig?.minimumSuccessDisplayTime = 3
        kvnConfig?.minimumErrorDisplayTime = 3
        KVNProgress.setConfiguration(kvnConfig)
        NetworkService.environment = .production //UserDefaults.standard.bool(forKey: SettingsIsProductionEnabledKey) ? .production : .staging
    }
}
