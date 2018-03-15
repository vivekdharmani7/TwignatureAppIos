//
//  BaseViewController.swift
//  Twignature
//
//  Created by Ivan Hahanov on 5/12/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        print("\(type(of: self)) deinit")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
	
	override var shouldAutorotate: Bool {
		return false
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return UIInterfaceOrientationMask.portrait
	}
	
	override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
		return UIInterfaceOrientation.portrait
	}
    
    // MARK: - Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Utils
    
    // MARK: - IBActions
    @IBAction fileprivate func dismissKeyboard(sender: Any) {
        view.endEditing(true)
    }	
}

extension BaseViewController: UIGestureRecognizerDelegate {
    
}
