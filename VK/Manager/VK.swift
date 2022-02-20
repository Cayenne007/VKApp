//
//  VK.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation
import UIKit


fileprivate enum URLS: Equatable {

    private static let baseUrl = "https://api.vk.com/method".url
    
    case friends
    case news
    case groups
    case groupByIds(ids: String)
    case userByIds(ids: String)
    
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
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .friends:
            return [
                URLQueryItem(name: "fields", value: "online,contacts,status,nickname,first_name,last_name,photo_100,is_friend")
            ]
        case .news:
            return [
                URLQueryItem(name: "filters", value: "post,photo")
            ]
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
        }
    }
    
}


struct VK {
    
    static var api = VK()
    
    func fetchData() {
        
        let dispatchGroup = DispatchGroup()
                
        fetchObjectsById(path: .groups, group: dispatchGroup)
        fetchFriends(group: dispatchGroup)
        fetchNewsfeed(group: dispatchGroup)
        
        dispatchGroup.notify(queue: .global()) {
            DB.vk.users.sort{$0.name < $1.name}
            DB.vk.groups.sort{$0.name < $1.name}
            
            NotificationCenter.default.post(name: Notification.Name("update"), object: nil)
        }
        
    }
    
    private func fetchObjectsById(path: URLS, group: DispatchGroup) {
        
        group.enter()
        
        URLSession.shared.requestJsonResponseItems(path.url, decode: Int.self) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let ids):
                let ids = ids.map{String($0)}.joined(separator: ",")
                
                if path == .groups {
                    fetchGroupsByIds(ids: ids, group: group)
                } else if path == .friends {
                    fetchUsersByIds(ids: ids, group: group)
                }
                
                group.leave()
            }
            
        }
        
    }
    

    private init() {}
    
}


extension VK {
    
    private func fetchFriends(group: DispatchGroup) {
        
        URLSession.shared.request(URLS.buildUrl(.friends),
                                  decode: JsonFriendsData.self) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                addUsers(items: result.response.items, group: group)
            }
        }
        
    }
    
}


extension VK {
    
    private func fetchUsersByIds(ids: String, group: DispatchGroup) {

        group.enter()
        
        let url = URLS.buildUrl(.userByIds(ids: ids))
        URLSession.shared.requestJsonResponseItems(url, decode: JsonUser.self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let json):
                addUsers(items: json, group: group)
                group.leave()
            }
        }
        
    }
    
    private func addUsers(items: [JsonUser], group: DispatchGroup) {
        
        group.enter()
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.users.first(where: {$0.id == json.id}) == nil {
                    let user = VKUser(id: json.id,
                                      firstName: json.firstName,
                                      lastName: json.lastName,
                                      isFriend: json.isFriend?.bool ?? false,
                                      photo: json.photo100
                    )
                                        
                    DB.vk.users.append(user)
                }
                
            }
            group.leave()
        }
    }

    
}

extension VK {
    
    private func fetchGroupsByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.groupByIds(ids: ids))
        URLSession.shared.requestJsonResponseObjects(url, decode: JsonGroup.self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let json):
                addGroups(items: json, group: group)
                group.leave()
            }
        }
    
    }
    
    private func addGroups(items: [JsonGroup], group: DispatchGroup) {
        
        group.enter()
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.groups.first(where: {$0.id == json.id}) == nil {
                    let group = VKGroup(id: json.id,
                                        name: json.name,
                                        isMember: json.isMember.bool,
                                        photo: json.photo100
                    )
                                        
                    DB.vk.groups.append(group)
                }
                
            }
            group.leave()
        }
    }
    
}


extension VK {
    
    func fetchNewsfeed(group: DispatchGroup) {
        
        group.enter()
        
        URLSession.shared.request(URLS.buildUrl(.news),
                                  decode: JsonNewsfeedData.self) { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                addUsers(items: result.response.profiles, group: group)
                addGroups(items: result.response.groups, group: group)
                setNewsfeedData(response: result.response)
                group.leave()
            }
        }
        
    }
    
    private func setNewsfeedData(response: JsonNewsfeedData.JsonNewsfeedResponse) {
        
        DB.vk.newsfeed = response.items.map { json in
            VKNews(sourceId: json.sourceID,
                   date: Date(timeIntervalSince1970: Double(json.date)),
                   id: json.postID ?? 0,
                   text: json.text ?? "",
                   likes: json.likes?.count ?? 0,
                   userLikes: json.likes?.userLikes ?? 0,
                   comments: json.comments?.count ?? 0,
                   reposts: json.reposts?.count ?? 0,
                   userReposts: json.reposts?.userReposted ?? 0,
                   views: json.views?.count ?? 0,
                   photos: json.attachments?
                    .filter{$0.type == .photo}
                    .map{$0.photo?.sizes.last?.url ?? ""}
                    .filter{!$0.isEmpty} ?? []
                   )                                
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
        ] + type.queryItems
        
        
        return components!.url!
        
    }
    
    
    
}

