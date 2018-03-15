//
//  FloatingButton.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/18/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class FloatingButton: UIButton {
	
  func changeTweeterButtonVisibility(_ visible: Bool) {
        guard let container = superview else { return }
        let buttonHeight = frame.size.height
        let buttonBottomMargin = container.frame.size.height - frame.maxY
        let translationY = buttonHeight + buttonBottomMargin
        UIView.animate(withDuration: 0.1, delay: 0.5, animations: {
            let transfrom = visible ? CGAffineTransform.identity : CGAffineTransform(translationX: 0,
                                                                                     y: translationY)
            self.transform = transfrom
        })
    }
}
