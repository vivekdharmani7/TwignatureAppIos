//
//  InfiniteScroll.swift
//  Twignature
//
//  Created by Ivan Hahanov on 7/21/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

private let kContentOffset = "contentOffset"
private let spinnerHeight: CGFloat = 40

class InfiniteScroll: NSObject {
    private unowned let tableView: UITableView
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var lastOffset: CGFloat = 0
    private var isVisible: Bool = false {
        didSet {
            if isVisible {
                spinner.startAnimating()
                layoutSpinner()
                action?()
            } else {
                spinner.stopAnimating()
                tableView.tableFooterView = nil
            }
        }
    }
    
    var shouldShowSpinner: (() -> Bool)?
    var action: Closure<Void>?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        tableView.addObserver(self, forKeyPath: kContentOffset, options: [.old, .new], context: nil)
        layoutSpinner()
    }

    private func layoutSpinner() {
        tableView.tableFooterView = spinner
        tableView.tableFooterView?.frame.size = CGSize(width: tableView.bounds.width, height: spinnerHeight)
    }
    
    func remove() {
        end()
        tableView.removeObserver(self, forKeyPath: kContentOffset)
    }
    
    func end() {
        isVisible = false
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == kContentOffset {
            guard tableView.contentSize.height > tableView.bounds.height else { return }
            let totalOffset = tableView.bounds.height + tableView.contentOffset.y
            if totalOffset > tableView.contentSize.height && lastOffset != totalOffset {
                let shouldInfiniteScroll = shouldShowSpinner?() ?? true
                if shouldInfiniteScroll != isVisible {
                    isVisible = shouldInfiniteScroll
                }
            }
            lastOffset = totalOffset
        }
    }
}
