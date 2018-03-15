//
//  NibLoadable.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

protocol NibLoadable: class {
    static func nibView() -> Self?
}

extension NibLoadable {
    
    static func nibView() -> Self? {
        return Bundle(for: self).loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? Self
    }
}
