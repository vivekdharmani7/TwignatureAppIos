//
//  MediaHeaderView.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/11/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

final class MediaHeaderView: UIView, NibLoadable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    var buttonCallback: Closure<Void>?
    
    @IBAction fileprivate func didPressButton(_ sender: Any) {
        buttonCallback?()
    }
}
