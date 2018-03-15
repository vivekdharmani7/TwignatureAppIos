//
//  VideoInfo.swift
//  Twignature
//
//  Created by Anton Muratov on 9/15/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct VideoInfo {
    let durationMilliseconds: UInt64
    let items: [VideoItem]
}

extension VideoInfo: ImmutableMappable {
    
    init(map: Map) throws {
        self.durationMilliseconds = try map.value("duration_millis")
        self.items = try map.value("variants")
    }
}
