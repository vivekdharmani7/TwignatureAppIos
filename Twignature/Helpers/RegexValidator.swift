//
//  RegexValidator.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/15/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

struct RegexValidator {
    
    private let pattern: String
    
    init(pattern: String) {
        self.pattern = pattern
    }
    
    func matches(for string: String) -> [NSTextCheckingResult] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))
        return matches
    }
}
