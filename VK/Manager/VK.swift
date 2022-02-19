//
//  VK.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation
import Alamofire


fileprivate enum URLS: String {

    private static let baseUrl = "https://api.vk.com/method".url
    
    case friends = "friends.get"
    case news = "newsfeed.get"
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .friends:
            return [
                URLQueryItem(name: "fields", value: "online,contacts,status,nickname,first_name,last_name,photo_100")
            ]
        case .news:
            return [
                URLQueryItem(name: "filters", value: "post,photo")//,
                //URLQueryItem(name: "source_ids", value: "107476823")
            ]
        }
    }
    
}


struct VK {
    
    static func getFriends(_ completion: @escaping ([JsonFriend])->()) {
        
        guard !AppSettings.token.isEmpty else {
            return
        }
        
        AF.request(URLS.buildUrl(.friends))
            .responseDecodable(of: JsonFriendsData.self) { response in
            switch response.result {
            case .success(let result):
                if response.response?.statusCode == 200 {
                    completion(result.response.items)
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
    
    static func getNews(_ completion: @escaping ()->()) {
        
        if AppSettings.isTest {
            setTestData(completion)
            return
        }
        
        guard !AppSettings.token.isEmpty else {
            return
        }
        
        AF.request(URLS.buildUrl(.news))
            .responseDecodable(of: JsonNewsfeedData.self) { response in
            switch response.result {
            case .success(let result):
                if response.response?.statusCode == 200 {
                    setNewsfeedData(response: result.response, completion)
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
    
}

extension VK {
    private static func setTestData(_ completion: ()->()) {
        if let url = Bundle.main.url(forResource: "testData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let result = try? JSONDecoder().decode(JsonNewsfeedData.self, from: data) {
             
            setNewsfeedData(response: result.response, completion)
             
        } else {
            return
        }
    }
    
    private static func setNewsfeedData(response: JsonNewsfeedResponse,_ completion: ()->()) {
        DB.vk.groups = response.groups.map{ json in
            VKGroup(id: json.id, name: json.name, photo: json.photo50)
        }
        
        DB.vk.users = response.profiles.map{ json in
            VKUser(id: json.id,
                   firstName: json.firstName,
                   lastName: json.lastName,
                   photo: json.photo50
            )
        }
        
        DB.vk.newsfeed = response.items.map { json in
            VKNews(author: DB.getAuthor(id: json.sourceID),
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
                    .map{$0.photo?.sizes.first?.url ?? ""}
                    .filter{!$0.isEmpty} ?? []
                   )                                
        }
        
        completion()
    }
    
}


extension URLS {
    
    static func buildUrl(_ type: URLS) -> URL {
        
        let url = baseUrl.appendingPathComponent(type.rawValue)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        components?.queryItems = [
            URLQueryItem(name: "access_token", value: AppSettings.token),
            URLQueryItem(name: "v", value: "5.131")
        ] + type.queryItems
        
        return components!.url!
        
    }
    
}
