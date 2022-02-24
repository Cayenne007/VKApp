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
        case .photos(let id):
            return [
                URLQueryItem(name: "owner_id", value: "\(id)")
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
        
    }
    
//    func fetchPhotos(owner: VKAuthor?, compeltion: @escaping ()->()) {
//        
//        guard let id = owner?._id else { return }
//        let minus = (owner is VKGroup) ? (-1) : (1)
//        
//        let url = URLS.buildUrl(.photos(ownerId: minus * id))
//        URLSession.shared.json(url,
//                               source: .responseItems,
//                               decode: [JsonPhoto].self) { result in
//            
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let objects):
//                addPhotos(items: objects, compeltion)
//            }
//        }
//        
//    }
    
    private func fetchObjectsById(path: URLS, group: DispatchGroup) {
        
        group.enter()
        
        let url = path.url
        URLSession.shared.json(url,
                               source: .responseItems,
                               decode: [Int].self) { result in
            
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
    
    private func addPhotos(items: [JsonPhoto], _ completion: @escaping ()->()) {
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.photos.first(where: {$0.id == json.id}) == nil {
                    
                    var url = ""
                    var image = UIImage(systemName: "photo")!
                    if let sizes = json.sizes {
                        url = sizes.sorted{$0.size > $1.size}.first?.url ?? ""
                        if !url.isEmpty, let url = URL(string: url),
                           let data = try? Data(contentsOf: url),
                           let loadedImage = UIImage(data: data) {
                            
                            image = loadedImage
                            
                        }
                    }
                    
                    let photo = VKPhoto(id: json.id,
                                        ownerId: json.ownerId,
                                        text: json.text ?? "",
                                        url: url
                    )
                    
                    photo.image = image
                    
                    DB.vk.photos.append(photo)
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                
            }
            
        }
        
    }
    
}

extension VK {
    
    private func fetchFriends(group: DispatchGroup) {
        
        let url = URLS.buildUrl(.friends)
        URLSession.shared.json(url,
                               source: .responseItems,
                               decode: [JsonUser].self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                addUsers(items: result, group: group)
            }
        }
        
    }
    
}


extension VK {
    
    private func fetchUsersByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.userByIds(ids: ids))
        
        URLSession.shared.json(url,
                               source: .itself,
                               decode: [JsonUser].self) { result in
            
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
        DispatchQueue.global().async(group: group) {
            DB.vk.addUser(items)
        }
    }
    
    
}

extension VK {
    
    private func fetchGroupsByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.groupByIds(ids: ids))
        URLSession.shared.json(url,
                               source: .response,
                               decode: [JsonGroup].self) { result in
            
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
        DB.vk.addGroup(items)
    }
    
}


extension VK {
    
    private func fetchNewsfeed(group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.news)
        
        URLSession.shared.json(url,
                               source: .response,
                               decode: JsonNewsfeedResponse.self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let result):
                addUsers(items: result.profiles, group: group)
                addGroups(items: result.groups, group: group)
                addNewsfeed(items: result.items, url: url)
                group.leave()
            }
        }
        
    }
    
    private func addNewsfeed(items: [JsonNewsfeedResponse.JsonNewsfeed], url: URL) {
        DB.vk.addNewsfeed(items, url: url)
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

