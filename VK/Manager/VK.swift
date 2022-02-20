//
//  VK.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation
import Alamofire


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
    
    var url: URL {
        URLS.buildUrl(self)
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
        URLSession.shared.dataTask(with: path.url) { data, response, error in
            
            if let error = NetworkError(data: data, response: response, error: error) {
                print(error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .fragmentsAllowed) as? [String : [String : Any]],
                   let items = json["response"]?["items"] as? [Int] {
                    
                    
                    let ids = items.map{String($0)}.joined(separator: ",")
                    
                    if path == .groups {
                        fetchGroupsByIds(ids: ids, group: group)
                    } else if path == .friends {
                        fetchUsersByIds(ids: ids, group: group)
                    }
                    
                    group.leave()
                    
                } else {
                    print("error decoding object ids")
                }
            } catch let error {
                print(NetworkError.decodingError(error))
                return
            }
            
            
            
        }.resume()
    }
    
    private func fetchGroupsByIds(ids: String, group: DispatchGroup) {
        
        URLSession.shared.dataTask(with: URLS.buildUrl(.groupByIds(ids: ids))) { data, response, error in
            if let error = NetworkError(data: data, response: response, error: error) {
                print(error)
                return
            }

            do {
                let json = try JSONDecoder().decode([String : [JsonGroup]].self, from: data!)
                if let objects = json["response"] {
                    addGroups(items: objects, group: group)
                } else {
                    print("error while decode groups by id")
                }
            } catch {
                print(NetworkError.decodingError(error))
                return
            }
        }.resume()
    }

    private func fetchUsersByIds(ids: String, group: DispatchGroup) {

        group.enter()
        URLSession.shared.dataTask(with: URLS.buildUrl(.userByIds(ids: ids))) { data, response, error in
            if let error = NetworkError(data: data, response: response, error: error) {
                print(error)
                return
            }
            
            do {
                let json = try JSONDecoder().decode([String : [JsonUser]].self, from: data!)
                if let objects = json["response"] {
                    DB.vk.users = objects.map{json in
                        VKUser(id: json.id,
                               firstName: json.firstName,
                               lastName: json.lastName,
                               isFriend: json.isFriend?.bool ?? false,
                               photo: json.photo100
                        )
                    }
                    group.leave()
                } else {
                    print("error decoding users by ids")
                }
            } catch {
                print(NetworkError.decodingError(error))
                return
            }
        }.resume()
    }

    
    
    private func fetchFriends(group: DispatchGroup) {
        
        AF.request(URLS.buildUrl(.friends))
            .responseDecodable(of: JsonFriendsData.self) { response in
            switch response.result {
            case .success(let result):
                if response.response?.statusCode == 200 {
                    addUsers(items: result.response.items, group: group)
                } else {
                    print("incorrect status code \(response.response!.statusCode)")
                }
            default :
                if let error = response.error {
                    print(error)                    
                }
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
    
    private func addGroups(items: [JsonGroup], group: DispatchGroup) {
        
        group.enter()
        
        DispatchQueue.global().async(flags: .barrier) {
            items.forEach{ json in
                if DB.vk.groups.first(where: {$0.id == json.id}) == nil {
                    let group = VKGroup(id: json.id,
                                        name: json.name,
                                        photo: json.photo100
                    )
                                        
                    DB.vk.groups.append(group)
                }
                
            }
            group.leave()
        }
    }
    
    func fetchNewsfeed(group: DispatchGroup) {
        
        group.enter()
        AF.request(URLS.buildUrl(.news))
            .responseDecodable(of: JsonNewsfeedData.self) { response in
            switch response.result {
            case .success(let result):
                if response.response?.statusCode == 200 {
                    addUsers(items: result.response.profiles, group: group)
                    addGroups(items: result.response.groups, group: group)
                    setNewsfeedData(response: result.response)
                    group.leave()
                } else {
                    print("incorrect status code \(response.response!.statusCode)")
                }
            default :
                if let error = response.error {
                    print(error)
                    group.leave()
                }
            }
        }
    }
    
    
    private init() {}
    
}

extension VK {
    private func setTestData(_ completion: ()->()) {
        if let url = Bundle.main.url(forResource: "testData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let result = try? JSONDecoder().decode(JsonNewsfeedData.self, from: data) {
             
            setNewsfeedData(response: result.response)
             
        } else {
            return
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




fileprivate enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case noData
    case decodingError(Error)
    case encodingError(Error)
}

extension NetworkError {
    init?(data: Data?, response: URLResponse?, error: Error?) {
            if let error = error {
                self = .transportError(error)
                return
            }

            if let response = response as? HTTPURLResponse,
                response.statusCode != 200 {
                self = .serverError(statusCode: response.statusCode)
                return
            }
            
            if data == nil {
                self = .noData
            }
            
            return nil
        }
}
