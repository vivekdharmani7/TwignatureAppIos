//
//  UIImageViewExtensions.swift
//  Twignature
//
//  Created by Anton Muratov on 9/12/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Kingfisher
import TwitterKit

extension UIImageView {
	
    func setImage(with url: URL?, placeholderImage: UIImage? = nil) {
		kf.setImage(with: url, placeholder: placeholderImage)
    }
	
	func setTwitterPrivateImage(with url: URL?, completion: (() -> Void)? = nil) {
		kf.setImage(with: url, options: [.requestModifier(modifier)]) { [weak self]  (image, error, _, _) in
			if error == nil && image != nil {
				DispatchQueue.main.async {
					self?.image = image
					completion?()
				}
			}
		}
	}
}

private let modifier = AnyModifier { request in
	var error: NSError?
	guard let twitterApiClient = Session.current?.twitterApiClient,
		let urlstr = request.url?.absoluteString else {
			return request
	}
	
	let twitterRequest = twitterApiClient.urlRequest(withMethod: "GET",
	                                                 url: urlstr,
	                                                 parameters: nil,
	                                                 error: &error)
	return twitterRequest
}
