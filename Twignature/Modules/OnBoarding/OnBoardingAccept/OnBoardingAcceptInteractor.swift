//
//  OnBoardingAcceptInteractor.swift
//  Twignature
//
//  Created by mac on 18.09.17.
//  Copyright (c) 2017 Applikey. All rights reserved.
//

import Foundation
import LocalAuthentication

class OnBoardingAcceptInteractor {
    weak var presenter: OnBoardingAcceptPresenter!
	
	func authenticateUser(completion: @escaping ResultClosure<Void>) {
		let context = LAContext()
		var error: NSError?
		guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else { return }
		context.evaluatePolicy(.deviceOwnerAuthentication,
		                       localizedReason: R.string.tweets.authenticationReason()) { success, error in
								if success {
									DispatchQueue.main.async {
										completion(.success())
									}
								} else {
									print(error!.localizedDescription)
									switch (error! as NSError).code {
										
									case LAError.systemCancel.rawValue:
										print("Authentication was cancelled by the system")
										
									case LAError.userCancel.rawValue:
										print("Authentication was cancelled by the user")
										
									case LAError.userFallback.rawValue:
										print("User selected to enter custom password")
										
									default:
										DispatchQueue.main.async {
											completion(.failure(error!))
										}
									}
								}
		}
	}
}
