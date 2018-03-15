//
//  Identifierable.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

protocol Identifierable {
    static var identifier: String { get }
}

extension Identifierable {
    static var identifier: String {
        return String(describing: Self.self)
    }
}
