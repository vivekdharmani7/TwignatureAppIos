//
//  TimezoneDateFormatterTransform.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import ObjectMapper

class TimezoneDateFormatterTransform: DateFormatterTransform {
    private let serverTimeZone: TimeZone
    private let destinationTimeZone: TimeZone
    
    init(dateFormatter: DateFormatter, serverTimeZone: TimeZone, destinationTimeZone: TimeZone) {
        self.serverTimeZone = serverTimeZone
        self.destinationTimeZone = destinationTimeZone
        super.init(dateFormatter: dateFormatter)
    }
    
    override func transformToJSON(_ value: Date?) -> String? {
        dateFormatter.timeZone = serverTimeZone
        return value.flatMap({ dateFormatter.string(from: $0) })
    }
    
    override func transformFromJSON(_ value: Any?) -> Date? {
        dateFormatter.timeZone = serverTimeZone
        let serverDate = (value as? String).flatMap({ dateFormatter.date(from: $0) })
        let serverDateString = serverDate.flatMap({ dateFormatter.string(from: $0) })
        dateFormatter.timeZone = destinationTimeZone
        return serverDateString.flatMap({ dateFormatter.date(from: $0) })
    }
}

