//
//  UserSettings.swift
//  Twignature
//
//  Created by user on 11/3/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct UserSetting {
    let displaySensitiveMedia: Bool
}

extension UserSetting: ImmutableMappable {
    init(map: Map) throws {
        displaySensitiveMedia = try map.value("display_sensitive_media")
    }
}
