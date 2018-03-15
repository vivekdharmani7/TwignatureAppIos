//
//  ChatInputView.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/5/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Chatto
import ChattoAdditions

protocol ChatInputViewDelegate: class {
	func editDidFinish(text: String)
	func pickImageAction()
}

final class ChatInputView: UIView, NibLoadable {

	weak var delegate: ChatInputViewDelegate?
	
	@IBOutlet weak var sendButton: UIButton!
	var maxCharactersCount: UInt?
	
	func setText(_ text: String) {
		textView.text = text
		textViewDidChange(textView)
	}
	
	@IBOutlet fileprivate weak var photoButton: UIButton!
	@IBOutlet private weak var inputContainer: UIView!
	fileprivate weak var textView: ExpandableTextView!
	@IBOutlet private weak var imageView: UIImageView!
	@IBOutlet private weak var attachmentsContainer: UIView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		let textView = ExpandableTextView()
		inputContainer.addSubview(textView)
		textView.pinToSuperview()
		textView.setTextPlaceholder("Your message…")
		textView.delegate = self
		textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		textView.setTextPlaceholderColor(UIColor.lightGray)
		textView.returnKeyType = .default
		self.textView = textView
		attachmentsContainer.isHidden = true
		textView.text = ""
	}
	
	@IBAction func sendButtonDidTap(_ sender: Any) {
		delegate?.editDidFinish(text: textView.text ?? "")
	}
	
	@IBAction func photoDidTap(_ sender: Any) {
		delegate?.pickImageAction()
	}
	
	func setImage(_ image: UIImage?) {
		imageView.image = image
		attachmentsContainer.isHidden = image == nil
		updateSendButton()
	}
	
	@IBAction func removeAttachmentDidTap(_ sender: Any) {
		setImage(nil)
	}
	
	fileprivate func updateSendButton() {
		sendButton.isEnabled = !(textView.text?.isEmpty ?? true) || imageView.image != nil
	}
}

extension ChatInputView: UITextViewDelegate {

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		guard let currentText = textView.text else { return true }
		
		if let maxCharactersCount = self.maxCharactersCount {
			var s = currentText
			s.replaceString(in: range, with: text)
			return s.characters.count <= maxCharactersCount
		}
		
		return true
	}
	
	func textViewDidChange(_ textView: UITextView) {
		updateSendButton()
	}
	
}
