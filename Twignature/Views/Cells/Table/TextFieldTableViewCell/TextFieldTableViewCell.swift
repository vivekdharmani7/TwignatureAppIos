//
//  TextFieldTableViewCell.swift
//  Twignature
//
//  Created by mac on 13.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
import JVFloatLabeledTextField

class TextFieldTableViewCell: UITableViewCell {

	@IBOutlet private weak var titleLabel: UILabel!
	@IBOutlet private weak var textField: UITextField!
	
	var didEndEditingHandler: ((String) -> ())?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		textField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func setTitle(_ title: String) {
		titleLabel.text = title
	}
	
	func setFieldText(_ text: String) {
		textField.text = text
	}
	
	func getFieldText() -> String {
		return textField.text ?? ""
	}
}

extension TextFieldTableViewCell: UITextFieldDelegate {
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let total = (textField.text! as NSString).replacingCharacters(in: range, with: string)
		didEndEditingHandler?(total)
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		
	}
}
