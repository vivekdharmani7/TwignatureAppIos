//
//  TwitterDateFormatter.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class TwitterDateFormatter: DateFormatter {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormat = Format.Date.twitter
		self.locale = Locale(identifier: "en_US_POSIX")
    }
    
    override init() {
        super.init()
        self.dateFormat = Format.Date.twitter
		self.locale = Locale(identifier: "en_US_POSIX")    }
}
