//
//  AvatarContainerView.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/4/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class AvatarContainerView: UIView {
    
    let imageView: UIImageView = UIImageView()
    
    override var tintColor: UIColor! {
        didSet {
            backgroundColor = tintColor
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        addSubview(imageView)
        imageView.clipsToBounds = true
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
    }
    
    // MARK: - Lifecycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds.insetBy(dx: 3, dy: 3)
        imageView.frame.origin = CGPoint(x: 3, y: 3)
        imageView.cornerRadius = imageView.bounds.height / 2
        cornerRadius = bounds.height / 2
        imageView.contentMode = .scaleAspectFill
    }
}
