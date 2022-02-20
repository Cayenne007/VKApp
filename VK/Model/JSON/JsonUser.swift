//
//  JsonUser.swift
//  VK
//
//  Created by Vladlen Sukhov on 19.02.2022.
//

import Foundation

// MARK: - Profile
struct JsonUser: Codable {
    let id: Int
    let firstName, lastName: String
    let canAccessClosed, isClosed: Bool?
    let isFriend: Int?
    let sex: Int?
    let screenName: String?
    let photo50, photo100: String?
    let onlineInfo: OnlineInfo?
    let online: Int?
    let onlineMobile, onlineApp: Int?
    let deactivated: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case canAccessClosed = "can_access_closed"
        case isClosed = "is_closed"
        case isFriend = "is_friend"
        case sex
        case screenName = "screen_name"
        case photo50 = "photo_50"
        case photo100 = "photo_100"
        case onlineInfo = "online_info"
        case online
        case onlineMobile = "online_mobile"
        case onlineApp = "online_app"
        case deactivated
    }
    
    // MARK: - OnlineInfo
    struct OnlineInfo: Codable {
        let visible, isOnline, isMobile: Bool
        let lastSeen, appID: Int?
        
        enum CodingKeys: String, CodingKey {
            case visible
            case isOnline = "is_online"
            case isMobile = "is_mobile"
            case lastSeen = "last_seen"
            case appID = "app_id"
        }
    }
    
}
