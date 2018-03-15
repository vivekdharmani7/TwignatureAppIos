//
//  KeyboardObserver.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/16/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

class KeyboardObserver {
    
    typealias KeyboardAttribures = (height: CGFloat, animationDuration: TimeInterval)
    
    init(onReveal: @escaping Closure<KeyboardAttribures>, onCollapse: @escaping Closure<KeyboardAttribures>) {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let attrs = self?.keyboardAttribures(from: notification) else { return }
            onReveal(attrs)
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide,
                                               object: nil,
                                               queue: .main) { [weak self] notification in
            guard let attrs = self?.keyboardAttribures(from: notification) else { return }
            onCollapse(attrs)
        }
    }
    
    private func keyboardAttribures(from notification: Notification) -> KeyboardAttribures {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let animationDuration = userInfo.value(forKey: UIKeyboardAnimationDurationUserInfoKey) as! Double
        let keyboardHeight = keyboardRectangle.height
        return (height: keyboardHeight, animationDuration: animationDuration)
    }
    
}
