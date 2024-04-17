//
//  YoutubeSearchResponse.swift
//  Netflix Clone
//
//  Created by Sahil Saxena on 14/03/24.
//

import Foundation

struct YoutubeSearchResponse: Codable {
    let items: [VideoElement]
}

struct VideoElement: Codable {
    let id: IdVideoElement
}

struct IdVideoElement: Codable {
    let kind: String
    let videoId: String
}
