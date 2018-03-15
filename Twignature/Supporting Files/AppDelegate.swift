//
//  AppDelegate.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/29/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import TwitterKit
import SideMenu
import IQKeyboardManagerSwift
import RKDropdownAlert
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppFlow!

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        ServicesConfigurator.application(application, didFinishLaunchingWithOptions: launchOptions)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
		SideMenuManager.menuFadeStatusBar = false
		IQKeyboardManager.sharedManager().enable = true
		
        appCoordinator = AppFlow(window: window!)
        appCoordinator.startAppFlow()
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)//UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        Session.current?.updateSessionSensetive()
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let windowRoot = window?.rootViewController,
            let controller = UIViewController.topViewController(from: windowRoot),
            controller is CreateTweetViewController || controller is BrushSettingsViewController {
            return controller.supportedInterfaceOrientations
        } else {
            return .portrait
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //store device token
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print(token)
        UserDefaults.standard.set(token, forKey: Key.pushTokenKey)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        PushNotificationsHandler.handlePushNotification(userInfo: userInfo,
                                                        state: application.applicationState,
                                                        coordinator:appCoordinator)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {    }
}
