//
//  BaseNavigationController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 10/17/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}
