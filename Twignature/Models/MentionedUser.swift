//
//  MentionedUser.swift
//  Twignature
//
//  Created by Anton Muratov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct MentionedUser {
    let id: String
    let name: String
    let screenName: String
}

extension MentionedUser: ImmutableMappable {
    
    init(map: Map) throws {
        self.id = try map.value("id_str")
        self.name = try map.value("name")
        self.screenName = try map.value("screen_name")
    }
}
