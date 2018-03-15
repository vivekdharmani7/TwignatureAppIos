//
//  BaseInteractor.swift
//  Twignature
//
//  Created by Ivan Hahanov on 8/4/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation

class BaseInteractor: NSObject {
    lazy var operationQueue = OperationQueue()
    lazy var networkService: NetworkService = NetworkService()
    
    var workItem: DispatchWorkItem!
    
    func add<Resource: JSONRequest>(request: Resource, completion: @escaping ResultClosure<Resource.Model>) {
        operationQueue.addOperation(NetworkOperation<Resource, NetworkService>(request: request, completion: completion))
    }
    
    func debounce(sec: TimeInterval, completion: @escaping Closure<Void>) {
        workItem?.cancel()
        workItem = DispatchWorkItem { completion() }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + sec, execute: workItem)
    }
	
	func openUrl(_ url: URL) {
		guard UIApplication.shared.canOpenURL(url) else { return }
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url)
		} else {
			UIApplication.shared.openURL(url)
		}
	}
}
