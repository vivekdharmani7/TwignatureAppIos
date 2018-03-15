//
// Created by mac on 29.11.2017.
// Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation

class BrushSettingsModel {

	var hue: CGFloat = 0
	var saturation: CGFloat = 0
	var brightness: CGFloat = 0
	var size: CGFloat = 0

	var colors: [String] = []
	let sizes: [CGFloat] = [2, 4, 6, 8]

	func getCurrentColor() -> UIColor {
		return UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: 1.0)
	}

	init(withColor color: UIColor) {
		update(withColor: color)
		updateColorsFromPlist()
	}

	func updateColorsFromPlist() {
		self.colors = []
		guard let colors = UserDefaults.standard.value(forKey: "savedColors") as? [String] else {
			return
		}
		self.colors = colors
	}

	func setColorsToPlist() {
		UserDefaults.standard.set(colors, forKey: "savedColors")
	}

	func update(withColor color: UIColor) {
		var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
		let ok: Bool = color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		if (!ok) {
			print("SwiftHSVColorPicker: exception <The color provided to SwiftHSVColorPicker is not convertible to HSV>")
		}
		self.hue = hue
		self.saturation = saturation
		self.brightness = brightness
	}

}