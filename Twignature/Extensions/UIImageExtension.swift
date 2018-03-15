//
//  UIImageExtension.swift
//  Twignature
//
//  Created by Pavel Yevtukhov on 10/24/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension UIImage {
	convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: .zero, size: size)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
		color.setFill()
		UIRectFill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		guard let cgImage = image?.cgImage else { return nil }
		self.init(cgImage: cgImage)
	}
	
	func resize(to size: CGSize) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
		let rect = CGRect(origin: CGPoint.zero, size: size)
		draw(in: rect)
		let resized = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return resized
	}
	
	var string: NSAttributedString {
		let attachment = NSTextAttachment()
		attachment.image = self
		attachment.bounds = CGRect(x: 0, y: -4, width: size.width, height: size.height)
		return NSAttributedString(attachment: attachment)
	}
	
	func scaleToFitSize(_ newSize: CGSize) -> UIImage {
		var scaledImageRect = CGRect.zero
		
		let aspectWidth = newSize.width / size.width
		let aspectheight = newSize.height / size.height
		
		let aspectRatio = max(aspectWidth, aspectheight)
		
		scaledImageRect.size.width = size.width * aspectRatio
		scaledImageRect.size.height = size.height * aspectRatio
		scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
		scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
		
		UIGraphicsBeginImageContext(newSize)
		draw(in: scaledImageRect)
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return scaledImage!
	}	
}
