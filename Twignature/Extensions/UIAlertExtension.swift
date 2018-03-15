//
//  UIAlertExtension.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/10/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func alert(title: String? = nil, message: String? = nil, style: UIAlertControllerStyle = .alert) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        return alert
    }
    
    func action(title: String? = "OK",
                style: UIAlertActionStyle = .default,
                block: Closure<UIAlertAction>? = nil) -> UIAlertController {
        let alertAction = UIAlertAction(title: title, style: style, handler: block)
        addAction(alertAction)
        return self
    }
    
//    func cancelAction() -> UIAlertController {
//        return self.action(title: "", style: .cancel)
//    }
    
}
