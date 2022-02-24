//
//  DB.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import RealmSwift

class DB {
    
    static var vk = DB()
    
    var photos: [VKPhoto] = []
    
    
    func addGroup(_ items: [JsonGroup]) {
        
        let db = try! Realm()
        
        let objectIds = Array(db.objects(VKGroup.self).map{$0.id})
        
        let objects = items.filter{!objectIds.contains($0.id)}
            .map { json in
                            
                VKGroup(id: json.id,
                        name: json.name,
                        isMember: json.isMember.bool,
                        photoUrl: json.photo100
                )
            }
        if objects.count > 0 {
            try! db.write {
                db.add(objects, update: .all)
            }
        }
        
        DispatchQueue.global().async {
            let db = try! Realm()
            db.objects(VKGroup.self).filter{!$0.photoUrl.isEmpty && $0.photo == nil}.forEach{ object in
                if let url = URL(string: object.photoUrl) {
                    try! db.write {
                        object.photo = try? Data(contentsOf: url)
                        db.add(object, update: .all)
                    }
                }
            }
        }
    }
    
    func addUser(_ items: [JsonUser]) {
        
        let db = try! Realm()
        
        let objectIds = Array(db.objects(VKUser.self).map{$0.id})
        
        let objects = items.filter{!objectIds.contains($0.id)}
            .map { json in
            VKUser(id: json.id,
                   firstName: json.firstName,
                   lastName: json.lastName,
                   isFriend: json.isFriend?.bool ?? false,
                   photoUrl: json.photo100 ?? ""
            )
        }
        
        if objects.count > 0 {
            try! db.write {
                db.add(objects, update: .all)
            }
        }
    
        DispatchQueue.global().async {
            let db = try! Realm()
            db.objects(VKUser.self).filter{!$0.photoUrl.isEmpty && $0.photo == nil}.forEach{ object in
                if let url = URL(string: object.photoUrl) {
                    try! db.write {
                        object.photo = try? Data(contentsOf: url)
                        db.add(object, update: .all)
                    }
                }
            }
        }
        
    }
    
    func addNewsfeed(_ items: [JsonNewsfeedResponse.JsonNewsfeed], url: URL) {
        
        let db = try! Realm()

        let objectIds = Array(db.objects(VKNews.self).map{$0.id})
        
        let objects = items.filter{!objectIds.contains($0.postID)}
            .map { json -> VKNews in
                
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
                              id: json.postID,
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
        
        if objects.count > 0 {
            try! db.write {
                db.add(objects, update: .all)
            }
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now()+5) {
            let db = try! Realm()
            db.objects(VKNews.self).filter{ $0.photoUrls.count > 0 && $0.photos.count == 0}.forEach{ object in
                for url in object.photoUrls{
                    if let url = URL(string: url) {
                        try! db.write {
                            let data = try? Data(contentsOf: url)
                            object.photos.append(data)
                        }
                    }
                }
            }
        }
        
    }



    private init() {}
    
}
