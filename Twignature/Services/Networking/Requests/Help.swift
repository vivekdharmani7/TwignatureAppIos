//
//  Help.swift
//  Twignature
//
//  Created by mac on 19.10.2017.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation

extension Request {
	struct Help: JSONRequest, MapperParsing {
		typealias Model = HelpConfiguration
		var path: String = "help/configuration.json"
	}
}
