//
//  TopBarItemView.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/1/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class TopBarItemView: UIView {
    
    var selectionClosure: Closure<Void>?
    var selected: Bool = false
    var image: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selected = false
    }

    @IBAction private func didSelectItem(_ sender: Any) {
        selectionClosure?()
    }
}
