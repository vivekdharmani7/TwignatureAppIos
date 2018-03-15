//
//  Constants.swift
//  Twignature
//
//  Created by user on 5/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit.UIColor

enum Links {
	static let terms = "https://signrs.com/terms"
	static let privacy = "https://signrs.com/privacy"
	static let supportMail = "mailto:support@signrs.com"
	static let twitterSafetySettings = "https://twitter.com/settings/safety"
}

enum Layout {
    static let navigationBarHeight: CGFloat = 64
    static let statusBarHeight: CGFloat = 20
    static let floatCellCornerRadius: CGFloat = 10
    static let defaultShadowOffset: CGSize = CGSize(width: 0, height: 3)
    static let defaultShadowOpacity: Float = 0.2
    static let defaultShadowRadius: CGFloat = 5
    static let mediaCellSpacing: CGFloat = 20
    static let userCellHeight: CGFloat = 78
}

enum Font {
    static func `default`(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size)
    }
    
    static func SFUIDisplayRegular(size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightMedium)
    }
    
    static func SFUITextRegular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: UIFontWeightRegular)
    }
}

enum Regex {
    static let hashtag = "(#[^\\s]+)"
    static let user = "@([A-Za-z]+[A-Za-z0-9]*)"//"@([A-Za-z]+[A-Za-z0-9]*)?"
}

enum Format {
    enum Date {
		static let fullForTwitterDetails = "dd MMMM yyyy, HH:mm"
        static let monthDayYearWithComa = "MMM, dd yyyy"
        static let monthDayYear = "MMM dd yyyy"
        static let `default` = "yyyy-MM-dd"
        static let full = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let twitter = "EEE MMM dd HH:mm:ss Z yyyy" //Tue Aug 28 21:08:15 +0000 2012
        static let monthDay = "MMM d"
        static let time = "h:mm a"
    }
    
    enum String {
        static let dateRange = "%@ - %@"
    }
}

enum Color {
    static let link = #colorLiteral(red: 0.007843137255, green: 0.5843137255, blue: 0.9568627451, alpha: 1)
    static let twitterBlue = #colorLiteral(red: 0.2701778114, green: 0.765666604, blue: 1, alpha: 1)
    static let lightGray = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    static let defaultShadow = UIColor.black
}

enum Key {
    static let sessionToken = "Session Token"
	static let onBoardingPressented = "TwignatureOnBoardingPressented"
	static let landscapeTipPressented = "LandscapeTipPressented"
    static let pushTokenKey = "TwignaturePushTokenKey"

    static let purchaseDraw = "com.twignature.PowerPen"
    static let isPowerPanPurchasedKey = "twignaturePowerPanPurchased"
}

enum NotificationIdentifier {
    static let SessionExpired = "Session Expired"
	static let FeedShouldReload = "FeedShouldReload"
}

enum PushNotificationCategory {
    static let verifiedCategory = "TWIGNATURE_NOTIFICATION_VERIFICATION"
}

enum CellIdentifier {
    static let `default` = "Default Cell"
}

enum AppDefined {
    static var maxTweetLettersNumber = 280
	static let maxBasicLettersNumber = 280
}

enum ErrorCode {
    static let unauthorized = 401
}
