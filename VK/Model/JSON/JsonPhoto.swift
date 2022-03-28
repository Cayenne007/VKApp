//
//  JsonPhoto.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation
import UIKit


struct JsonPhoto: Codable {
    let albumId: Int?
    let date: Int?
    let id, ownerId: Int
    let sizes: [JsonSize]?
    let text: String?
    let userId: Int?
    let hasTags: Bool?
    let accessKey: String?
    let postId: Int?
    
    enum CodingKeys: String, CodingKey {
        case albumId = "album_id"
        case date, id
        case ownerId = "owner_id"
        case sizes, text
        case userId = "user_id"
        case hasTags = "has_tags"
        case accessKey = "access_key"
        case postId = "post_id"
    }
}

// MARK: - Size
struct JsonSize: Codable {
    let height: Int?
    let url: String?
    let type: String?
    let width: Int?
    
    var size: Int {
        (height ?? 0) + (width ?? 0)
    }
    
    enum CodingKeys: String, CodingKey {
        case height, url, type, width
    }
}
