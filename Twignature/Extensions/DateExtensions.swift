//
//  DateExtensions.swift
//  Twignature
//
//  Created by Anton Muratov on 9/21/17.
//  Created by Pavel Yevtukhov on 9/21/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension Date {
    enum DateOffset {
        case seconds(Int)
        case minutes(Int)
        case hours(Int)
        case days(Int)
        case weeks(Int)
        case months(Int)
        case years(Int)

        var stringValue: String? {
            switch self {
            case let .years(years) where years > 0:
                return "\(years) \(years > 1 ? "years" : "year")"
            case let .months(months) where months > 0:
                return "\(months) \(months > 1 ? "months" : "month")"
            case let .weeks(weeks) where weeks > 0:
                return "\(weeks)w"
            case let .days(days) where days > 0:
                return "\(days)d"
            case let .hours(hours) where hours > 0:
                return "\(hours)h"
            case let .minutes(minutes) where minutes > 0:
                return "\(minutes)m"
            case let .seconds(seconds) where seconds > 0:
                return "\(seconds)s"
            default:
                return nil
            }
        }
    }

    func offset(from date: Date) -> DateOffset? {
        if years(from: date) > 0 { return .years(years(from: date)) }
        if months(from: date) > 0 { return .months(months(from: date)) }
        if weeks(from: date) > 0 { return .weeks(weeks(from: date)) }
        if days(from: date) > 0 { return .days(days(from: date)) }
        if hours(from: date) > 0 { return .hours(hours(from: date)) }
        if minutes(from: date) > 0 { return .minutes(minutes(from: date)) }
        if seconds(from: date) > 0 { return .seconds(seconds(from: date)) }
        return nil
    }

    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }

    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }

    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }

    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }

    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }

    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }

    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
}
