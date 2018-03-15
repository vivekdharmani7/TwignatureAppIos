//
//  MediaItem.swift
//  Twignature
//
//  Created by Ivan Hahanov on 9/10/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import Foundation
import ObjectMapper

struct MediaItem {
    enum `Type`: String {
        case photo
        case video
    }
    
    let url: URL
    let expandedUrl: URL
    let displayUrl: URL
    let mediaUrl: URL?
    let type: Type
    let videoInfo: VideoInfo?
    let possiblySensitive: Bool?
}

extension MediaItem: ImmutableMappable {
    
    init(map: Map) throws {
        self.url = try map.value("url", using: URLTransform())
        self.expandedUrl = try map.value("expanded_url", using: URLTransform())
        self.displayUrl = try map.value("display_url", using: URLTransform())
        self.mediaUrl = try map.value("media_url", using: URLTransform())
        self.type = try map.value("type", using: EnumTransform<`Type`>())
        self.videoInfo = try? map.value("video_info")
        self.possiblySensitive = try? map.value("possibly_sensitive")
    }
}
