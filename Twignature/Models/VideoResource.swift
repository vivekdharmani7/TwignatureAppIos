//
//  VideoResource.swift
//  Twignature
//
//  Created by Anton Muratov on 9/15/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct VideoItem {
    enum ContentType: String {
        case videoMp4 = "video/mp4"
        case mpegUrl = "application/x-mpegURL"
    }
    
    let bitrate: UInt64?
    let url: URL
    let contentType: ContentType
}

extension VideoItem: ImmutableMappable {
    
    init(map: Map) throws {
        self.bitrate = try? map.value("bitrate")
        self.url = try map.value("url", using: URLTransform())
        self.contentType = try map.value("content_type", using: EnumTransform<ContentType>())
    }
}
