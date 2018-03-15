//
//  FloatingTitledCell.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/6/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class FloatingTitledCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var container: UIView!
    
    var viewModel: ViewModel? {
        didSet {
            titleLabel.text = viewModel?.title
			if let countTitle = viewModel?.countTitle {
				countLabel.isHidden = false
				countLabel.text = String(countTitle)
			} else {
				countLabel.isHidden = true
			}
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        countLabel.clipsToBounds = true
        container.layer.shadowColor = Color.defaultShadow.cgColor
        container.layer.shadowOpacity = Layout.defaultShadowOpacity
        container.layer.shadowRadius = Layout.defaultShadowRadius
        container.layer.shadowOffset = Layout.defaultShadowOffset
        container.cornerRadius = Layout.floatCellCornerRadius
    }
}

extension FloatingTitledCell {
    struct ViewModel {
        let title: String
        let countTitle: Int?
        let selectionClosure: Closure<Void>?
    }
}
