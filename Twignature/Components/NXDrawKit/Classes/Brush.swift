//
//  Brush.swift
//  NXDrawKit
//
//  Created by Nicejinux on 7/12/16.
//  Copyright © 2016 Nicejinux. All rights reserved.
//

import UIKit

open class Brush: NSObject {
    @objc open var color: UIColor = UIColor.black {
        willSet(colorValue) {
            self.color = colorValue
            isEraser = color.isEqual(UIColor.clear)
            blendMode = isEraser ? .clear : .normal
        }
    }
    @objc open var width: CGFloat = 4.0
    @objc open var alpha: CGFloat = 1.0
    @objc open var defaultLineWidth: CGFloat = 6
    @objc open var forceSensitivity: CGFloat = 4.0
    @objc open var minLineWidth: CGFloat = 5
    @objc open var isWidthDynamic: Bool = false
    
    @objc internal var blendMode: CGBlendMode = .plusDarker
    @objc internal var isEraser: Bool = false
}
