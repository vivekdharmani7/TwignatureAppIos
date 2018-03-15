//
//  BrushSettingsProtocols.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit

protocol BrushSettingsCoordinator: CanShowBrushSettings {

}

//Brunch initial protocol
protocol CanShowBrushSettings {
	func showBrushSettings(withDelegate delegate: BrushSettingsDelegate?, selectedColor color: UIColor, andSelectedSize size: CGFloat)
}

extension BaseCoordinator where Self: BrushSettingsCoordinator {

	func showBrushSettings(withDelegate delegate: BrushSettingsDelegate?, selectedColor color: UIColor, andSelectedSize size: CGFloat) {
		let controller = R.storyboard.tweets.brushSettingsViewController()!
		BrushSettingsWireframe.setup(controller, withCoordinator: self) { presenter in
			presenter.delegate = delegate
			presenter.model.update(withColor: color)
			presenter.model.size = size/2
		}
		self.router.topController?.present(controller, animated: true)
	}
}

//Parent delegate
protocol BrushSettingsDelegate: class {
	func didSelectColor(_ color: UIColor)
	func didSelectBrushSize(_ size: CGFloat)
}