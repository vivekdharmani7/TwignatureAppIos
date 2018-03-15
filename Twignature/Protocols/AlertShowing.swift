//
//  AlertShowing.swift
//  Twignature
//
//  Created by Ivan Hahanov on 7/11/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import UIKit.UIViewController
import KVNProgress

protocol AlertShowing {
    func showAlert(with message: String)
    func showError(_ error: Error)
    func showError(_ message: String)
    func showSuccess(with message: String)
}

extension AlertShowing where Self: UIViewController {
    func showAlert(with message: String) {
        showAlert(message: message)
    }
	
	func showAgreeAlert(with message: String, agreeBlock: @escaping Closure<Void>) {
		let alert = UIAlertController.alert(title: title, message: message)
		_ = alert.action(title: "Cancel", style: .cancel, block: nil)
        _ = alert.action(title: "Ok", style: .default) { _ in
			agreeBlock()
		}
		present(alert, animated: true, completion: nil)
	}
    
    func show(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func showError(_ error: Error) {
        KVNProgress.showError(withStatus: error.localizedDescription)
    }
    
    func showError(_ message: String) {
        KVNProgress.showError(withStatus: message)
    }
    
    func showSuccess(with message: String) {
        KVNProgress.showSuccess(withStatus: message)
    }
    
    private func showAlert(title: String = "Alert", message: String) {
        let alert = UIAlertController.alert(title: title, message: message).action()
        present(alert, animated: true, completion: nil)
    }
}
