//
//  TextViewTableViewCell.swift
//  Twignature
//
//  Created by user on 10/27/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    
    var didEndEditingHandler: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func setFieldText(_ text: String) {
        textView.text = text
    }
    
    func getFieldText() -> String {
        return textView.text ?? ""
    }
}

extension TextViewTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let total = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        didEndEditingHandler?(total)
        return true
    }
}
