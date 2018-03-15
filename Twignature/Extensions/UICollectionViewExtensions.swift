//
//  UICollectionViewExtensions.swift
//  Twignature
//
//  Created by Anton Muratov on 9/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(_ resource: T.Type) {
        register(T.nib, forCellWithReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(resource: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T
    }
}
