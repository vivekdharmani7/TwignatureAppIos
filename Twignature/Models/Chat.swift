//
//  Chat.swift
//  Twignature
//
//  Created by Anton Muratov on 9/21/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import ObjectMapper

struct Chat {
   /* let id: String
    let createdAt: Date
    let sender: User
    let recipient: User
    let text: String*/
}

extension Chat: ImmutableMappable {
    
    init(map: Map) throws {
       /* self.id = try map.value("id_str")
        self.sender = try map.value("sender")
        self.recipient = try map.value("recipient")
        self.text = try map.value("text")
        let dateTransform = TimezoneDateFormatterTransform(dateFormatter: TwitterDateFormatter(),
                                                           serverTimeZone: .utc,
                                                           destinationTimeZone: .current)
        self.createdAt = try map.value("created_at", using: dateTransform)*/
    }
}
