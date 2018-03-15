//
//  PullToRefresh.swift
//  Twignature
//
//  Created by Ivan Hahanov on 7/21/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

private let tag = -9999

class PullToRefresh {
    unowned private let tableView: UITableView
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func add(target: Any?, action: Selector) {
        let refresher = UIRefreshControl()
        refresher.addTarget(target, action: action, for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            refresher.tag = tag
            tableView.addSubview(refresher)
        }
    }
    
    func end() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl?.endRefreshing()
        } else {
            (tableView.subviews
                .first(where: { $0.tag == tag }) as? UIRefreshControl)?
                .endRefreshing()
        }
    }
}
