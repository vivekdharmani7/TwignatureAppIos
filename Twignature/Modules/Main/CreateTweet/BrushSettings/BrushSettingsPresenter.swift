//
//  BrushSettingsPresenter.swift
//  Twignature
//
//  Created by mac on 28.11.2017.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift

class BrushSettingsPresenter: NSObject {
    
    //MARK: - Init
    required init(controller: BrushSettingsViewController,
                  interactor: BrushSettingsInteractor,
                  coordinator: BrushSettingsCoordinator) {
        self.coordinator = coordinator
        self.controller = controller
        self.interactor = interactor
    }
    
    //MARK: - Private -
    fileprivate let coordinator: BrushSettingsCoordinator
    fileprivate unowned var controller: BrushSettingsViewController
    fileprivate var interactor: BrushSettingsInteractor
	var model: BrushSettingsModel = BrushSettingsModel(withColor: .black)
	weak var delegate: BrushSettingsDelegate?

	func viewIsReady() {
		self.controller.colorCircleView.delegate = self
		self.controller.brightnessPicker.delegate = self
		self.controller.hexColorTextField.delegate = self
		self.controller.setColorsModel(self.model.colors)
		self.controller.setSizesModel(self.model.sizes)
		self.controller.selectedSize = self.model.size
		updateColor()
	}

	fileprivate func updateColor(_ needToChange: Bool = true) {
		let currentColor: UIColor = self.model.getCurrentColor()
		self.controller.configurePickerWithColor(currentColor, needToChange)
		self.delegate?.didSelectColor(currentColor)
	}

	func saveToStorageAction() {
		self.model.colors.append(self.model.getCurrentColor().hexString(false))
		self.model.setColorsToPlist()
		self.controller.setColorsModel(self.model.colors)
	}

	func selectedItemFromColors(onIndex index: Int) {
		let colorHex = self.model.colors[index]
		let color = UIColor(colorHex, defaultColor: self.model.getCurrentColor())
		self.model.update(withColor: color)
		updateColor()
	}

	func selectedItemFromSizes(onIndex index: Int) {
		let size = self.model.sizes[index]
		self.controller.selectedSize = size
		self.delegate?.didSelectBrushSize(size*2)
	}
}

extension BrushSettingsPresenter: ColorWheelDelegate, BrightnessViewDelegate {

	func hueAndSaturationSelected(_ hue: CGFloat, saturation: CGFloat) {
		self.model.hue = hue
		self.model.saturation = saturation
		updateColor(false)
	}

	func brightnessSelected(_ brightness: CGFloat) {
		self.model.brightness = brightness
		updateColor(false)
	}
}

extension BrushSettingsPresenter: UITextFieldDelegate {

	func textFieldDidEndEditing(_ textField: UITextField) {
		let text = textField.text ?? ""
		let color = UIColor(text, defaultColor: model.getCurrentColor())
		self.model.update(withColor: color)
		updateColor()
	}

	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let currentCharacterCount = textField.text?.characters.count ?? 0
		if (range.length + range.location > currentCharacterCount) {
			return false
		}
		let newLength = currentCharacterCount + string.characters.count - range.length
		return newLength <= 7
	}
}