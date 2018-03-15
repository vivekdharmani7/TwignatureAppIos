//
//  HUDShowing.swift
//  Twignature
//
//  Created by Ivan Hahanov on 7/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
//import MBProgressHUD
import KVNProgress
import UIKit

protocol HUDShowing {
    func showHUD()
    func hideHUD()
}

extension HUDShowing where Self: UIViewController {
    func showHUD() {
        KVNProgress.show()
//        guard let window = UIApplication.shared.keyWindow else { return }
//        MBProgressHUD.showAdded(to: window, animated: true)
    }
    
    func hideHUD() {
        KVNProgress.dismiss()
//        guard let window = UIApplication.shared.keyWindow else { return }
//        MBProgressHUD.hide(for: window, animated: true)
    }
	
	func showHUD(withText text: String) {
		KVNProgress.show(withStatus: text)
	}
}
