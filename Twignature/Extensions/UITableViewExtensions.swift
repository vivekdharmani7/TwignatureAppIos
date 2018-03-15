//
//  UITableViewExtensions.swift
//  Twignature
//
//  Created by Anton Muratov on 9/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit.UITableView

extension UITableView {
    var pullToRefresh: PullToRefresh {
        return PullToRefresh(tableView: self)
    }
    
    func register<T: UITableViewCell>(_ resource: T.Type) {
        register(T.nib, forCellReuseIdentifier: T.identifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(resource: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
}

extension UIScrollView {
    func set(scrollPosition position: CGFloat) {
        self.contentOffset = CGPoint(x: self.contentOffset.x, y: position)
    }
}
