//
//  CommonExtensions.swift
//  Twignature
//
//  Created by Ivan Hahanov on 5/15/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension UIDatePicker {
    static var birthdate: UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "en_US")
        return datePicker
    }
}

extension UIViewController {
    
    func attach(vc: UIViewController) {
        view.addSubview(vc.view)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
    }
    
    func detach(vc: UIViewController) {
        vc.willMove(toParentViewController: nil)
        vc.removeFromParentViewController()
        vc.view.removeFromSuperview()
    }
}

extension URL {
    init?(string: String?) {
        if let string = string {
            self.init(string: string)
        }
        return nil
    }
}

private let fakeDomain = "NSError fake domain"
private let fakeCode = -123

extension NSError {    
    static var unknown: NSError {
        return NSError(domain: fakeDomain, code: fakeCode, userInfo: [NSLocalizedDescriptionKey: "Unknown"])
    }
    
    static func `default`(message: String) -> NSError {
        return NSError(domain: fakeDomain, code: fakeCode, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
