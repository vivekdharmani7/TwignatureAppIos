//
//  Place.swift
//  Twignature
//
//  Created by Anton Muratov on 9/7/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct Place {
    let id: String
    let fullname: String
}

extension Place: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id")
        self.fullname = try map.value("full_name")
    }
}
