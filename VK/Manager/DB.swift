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
    
    var users: [VKUser] = []
    var friends: [VKUser] { users.filter{ $0.isFriend} }
    var newsfeed: [VKNews] = []
    var photos: [VKPhoto] = []
    
    static func getPhotos(owner: VKAuthor?) -> [VKPhoto] {
        
        guard let id = owner?._id else {
            return []
        }
        let minus = (owner is VKGroup) ? (-1) : (1)
        
        return DB.vk.photos.filter{$0.ownerId == minus * id}
        
    }
    
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



    private init() {}
    
}
