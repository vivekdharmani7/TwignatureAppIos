//
//  NetworkOperation.swift
//  Twignature
//
//  Created by Ivan Hahanov on 7/17/17.
//  Copyright © 2017 user. All rights reserved.
//

import Foundation
import Networking

class NetworkOperation<Resource: JSONRequest, Service: RequestService>: Operation {

    typealias ConditionBlock = () -> Bool
    
    enum State {
        case pending, executing, cancelled, finished
    }
    
    private let request: Resource
    private var service: Service
    private var completion: ResultClosure<Resource.Model>
    var conditions: [ConditionBlock] = []
    
    override var isFinished: Bool {
        return service.state == .finished
    }
    
    override var isExecuting: Bool {
        return service.state == .executing
    }
    
    override var isCancelled: Bool {
        return service.state == .cancelled
    }
    
    init(request: Resource,
         service: Service = Service(),
         completion: @escaping ResultClosure<Resource.Model>) {
        self.request = request
        self.service = service
        self.completion = completion
        super.init()
        self.service.didChangeState = { [unowned self] _ in
            self.willChangeValue(forKey: "isFinished")
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isCancelled")
            self.didChangeValue(forKey: "isFinished")
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isCancelled")
        }
    }

    override func main() {
        if verifyConditions() == false {
            return
        }
        if !self.isCancelled {
            execute()
        }
    }
    
    override func cancel() {
        service.cancelRequest()
    }
    
    private func verifyConditions() -> Bool {
        for condition in conditions {
            if isCancelled {
                return false
            }
            if condition() != true {
                return false
            }
        }
        return true
    }
    
    func execute() {
        if !self.isCancelled {
            service.fetch(resource: request) { model in
                DispatchQueue.main.async {
                    self.completion(model)
                }
            }
        }
    }
}
