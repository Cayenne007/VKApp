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
        
        dispatchGroup.notify(queue: .global()) {
            DB.vk.users.sort{$0.name < $1.name}
            DB.vk.groups.sort{$0.name < $1.name}
            
            Notifications.postObserverNotification()
        }
        
    }
    
    func fetchPhotos(owner: VKAuthor?, compeltion: @escaping ()->()) {
        
        guard let id = owner?.id else { return }
        let minus = (owner is VKGroup) ? (-1) : (1)
        
        let url = URLS.buildUrl(.photos(ownerId: minus * id))
        URLSession.shared.json(url,
                               source: .responseItems,
                               decode: [JsonPhoto].self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let objects):
                addPhotos(items: objects, compeltion)
            }
        }
        
    }
    
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
        
        group.enter()
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.users.first(where: {$0.id == json.id}) == nil {
                    let user = VKUser(id: json.id,
                                      firstName: json.firstName,
                                      lastName: json.lastName,
                                      isFriend: json.isFriend?.bool ?? false,
                                      photoUrl: json.photo100 ?? ""
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
        
        group.enter()
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.groups.first(where: {$0.id == json.id}) == nil {
                    let group = VKGroup(id: json.id,
                                        name: json.name,
                                        isMember: json.isMember.bool,
                                        photoUrl: json.photo100 
                    )
                    
                    DB.vk.groups.append(group)
                }
                
            }
            group.leave()
        }
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
        
        DB.vk.newsfeed = items.map { json in
            
            let urls = json.attachments?
                .filter{$0.type == "photo"}
                .map{ element -> String in
                    if let element = element.photo?.sizes?.first(
                        where: {$0.type == "x"})?.url {
                        return element
                    } else {
                        return ""
                    }
                }
                .filter{!$0.isEmpty} ?? []
            
            return VKNews(sourceId: json.sourceID,
                          date: Date(timeIntervalSince1970: Double(json.date)),
                          id: json.postID ?? 0,
                          text: json.text ?? "",
                          likes: json.likes?.count ?? 0,
                          userLikes: json.likes?.userLikes ?? 0,
                          comments: json.comments?.count ?? 0,
                          reposts: json.reposts?.count ?? 0,
                          userReposts: json.reposts?.userReposted ?? 0,
                          views: json.views?.count ?? 0,
                          photoUrls: urls,
                          url: url.withQueryItem(key: "source_ids", value: "\(json.sourceID)").description
            )
        }
        
        DispatchQueue.global().async {
            DB.vk.newsfeed.filter{$0.photoUrls.count > 0}.forEach{ object in
                for url in object.photoUrls {
                    if let url = URL(string: url) {
                       object.photos.append(try? Data(contentsOf: url))
                    } else {
                        object.photos.append(nil)
                    }
                    //NotificationCenter.default.post(name: Notification.Name("update"), object: self)
                }
                Notifications.postObserverNotification()
            }
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

