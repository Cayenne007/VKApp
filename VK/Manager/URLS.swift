//
//  URLS.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation


enum URLS: Equatable {
        
    static let baseUrl = "https://api.vk.com/method".url
    
    case friends
    case news(queryItems: [URLQueryItem] = [])
    case groups
    case groupByIds(ids: String)
    case userByIds(ids: String)
    case photos(ownerId: Int)
    
    var path: String {
        switch self {
        case .groups:
            return "groups.get"
        case .friends:
            return "friends.get"
        case .news:
            return "newsfeed.get"
        case .groupByIds:
            return "groups.getById"
        case .userByIds:
            return "users.getById"
        case .photos:
            return "photos.getAll"
        }
    }
    
    func queryItems() -> [URLQueryItem] {
                
        switch self {
        case .friends:
            return [
                URLQueryItem(name: "fields", value: "online,contacts,status,nickname,first_name,last_name,photo_100,is_friend")
            ]
        case .news(let queryItems):
            return [
                URLQueryItem(name: "filters", value: "post,photo"),
                URLQueryItem(name: "count", value: "5") //infinite scroll test
            ] + queryItems
            
        case .groups:
            return []
        case .groupByIds(let ids):
            return [
                URLQueryItem(name: "group_ids", value: ids)
            ]
        case .userByIds(let ids):
            return [
                URLQueryItem(name: "user_ids", value: ids),
                URLQueryItem(name: "fields", value: "is_friend")
            ]
        case .photos(let id):
            return [
                URLQueryItem(name: "owner_id", value: "\(id)")
            ]
        }
        
    }
    
}


extension URLS {
    
    var url: URL {
        URLS.buildUrl(self)
    }
    
    static func buildUrl(_ type: URLS) -> URL {
        
        let url = URLS.baseUrl.appendingPathComponent(type.path)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = [
            URLQueryItem(name: "access_token", value: AppSettings.token),
            URLQueryItem(name: "v", value: "5.131")
        ] + type.queryItems()
        
        
        return components!.url!
        
    }
    
}

