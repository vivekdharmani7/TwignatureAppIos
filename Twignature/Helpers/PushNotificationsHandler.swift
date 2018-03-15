//
//  PushNotificationsHandler.swift
//  Twignature
//
//  Created by Maxim Kamenev on 2/14/18.
//  Copyright © 2018 Applikey. All rights reserved.
//

import Foundation
import RKDropdownAlert

class PushNotificationsHandler {
    fileprivate static var networkService: RequestService = NetworkService()
    
    static func handlePushNotification(userInfo: [AnyHashable : Any],
                                       state: UIApplicationState,
                                       coordinator: AppFlow) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                let title = alert["title"] as? String
                let message = alert["body"] as? String
                if let title = title {
                    if let message = message {
                        RKDropdownAlert.title(title, message: message, backgroundColor: Color.twitterBlue, textColor: .white)
                    } else {
                        RKDropdownAlert.title(title, backgroundColor: Color.twitterBlue, textColor: .white)
                    }
                }
                if let category = aps["category"] as? String {
                    switch category {
                    case PushNotificationCategory.verifiedCategory:
                        showOnboardingIfNeeded(coordinator: coordinator)
                    default: ()
                    }
                }
            }

        }
        
    }
    
    static fileprivate func showOnboardingIfNeeded(coordinator: AppFlow) {
        updateCurrentUserInfo { (result) in
            switch result {
            case .success(let user):
                 Session.current?.updateSessionWithTempUser(user)
                guard let isVerified = user.isVerified else { return }
                if isVerified {
                    coordinator.startOnBoardingFlow()
                }
            default: ()
            }
        }
    }
    
    static fileprivate func updateCurrentUserInfo(_ completion: @escaping ResultClosure<TempUser>) {
        let request = Request.Users.Current()
        networkService.fetch(resource: request, completion: completion)
    }
    
}
