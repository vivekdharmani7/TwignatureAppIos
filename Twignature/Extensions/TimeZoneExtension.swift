//
//  TimeZoneExtension.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension TimeZone {
    
    static var utc: TimeZone {
        return TimeZone(abbreviation: "UTC")!
    }
}
