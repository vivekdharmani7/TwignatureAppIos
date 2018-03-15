//
//  NibProvider.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

protocol NibProvider { }

extension NibProvider where Self: UIView {
    static var nib: UINib? {
        return UINib(nibName: String(describing: Self.self),
                     bundle: Bundle(for: Self.self))
    }
}
