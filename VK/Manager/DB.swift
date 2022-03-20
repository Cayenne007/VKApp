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
    
    var photoService: PhotoService?
    
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
        
//        DispatchQueue.global().async {
//            let db = try! Realm()
//            db.objects(VKUser.self).filter{!$0.photoUrl.isEmpty && $0.photo == nil}.forEach{ object in
//                if let url = URL(string: object.photoUrl) {
//                    try! db.write {
//                        object.photo = try? Data(contentsOf: url)
//                        db.add(object, update: .all)
//                    }
//                }
//            }
//        }
        
    }
    
    func addNewsfeed(_ items: [JsonNewsfeedResponse.JsonNewsfeed], url: URL) {
        
        let db = try! Realm()
        let objectIds = Array(db.objects(VKNews.self).map{$0.id})
        
        items.forEach{ item in
            if let id = item.postID,
               !objectIds.contains(id) {
                self.addNewsfeed(json: item, url: url)
            }
        }
        
    }
    
    private func addNewsfeed(json: JsonNewsfeedResponse.JsonNewsfeed, url: URL){
        
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
        
        let db = try! Realm()
        let object = VKNews(sourceId: json.sourceID,
                            date: Date(timeIntervalSince1970: Double(json.date)),
                            id: json.postID!,
                            text: json.text ?? "",
                            likes: json.likes?.count ?? 0,
                            userLikes: json.likes?.userLikes ?? 0,
                            comments: json.comments?.count ?? 0,
                            reposts: json.reposts?.count ?? 0,
                            userReposts: json.reposts?.userReposted ?? 0,
                            views: json.views?.count ?? 0,
                            photoUrls: urls,
                            url: url.withQueryItem(key: "source_ids", value: "\(json.sourceID)").description,
                            postType: json.postType ?? "post"
        )
        
//        object.photoUrls.forEach{ url in
//            if let url = URL(string: url) {
//                object.photos.append(try? Data(contentsOf: url))
//            }
//        }
        
        do {
            try db.write{
                db.add(object, update: .all)
            }
        } catch {
            print(error)
        }
    }
    
    
    func addPhotos(items: [JsonPhoto]) {
        
        let db = try! Realm()
        
        let objectIds = Array(db.objects(VKPhoto.self).map{$0.id})
        
        let objects = items.filter{!objectIds.contains($0.id)}
            .map { json -> VKPhoto in
                
                var url = ""
                
                if let sizes = json.sizes {
                    url = sizes.sorted{$0.size > $1.size}.first?.url ?? ""
                }
                
                return VKPhoto(id: json.id,
                               ownerId: json.ownerId,
                               text: json.text ?? "",
                               url: url
                )
            }
        
        if objects.count > 0 {
            try! db.write {
                db.add(objects, update: .all)
            }
        }
        
//        DispatchQueue.global().async {
//            let db = try! Realm()
//            db.objects(VKPhoto.self).filter{!$0.url.isEmpty && $0.data == nil}.forEach{ object in
//                if let url = URL(string: object.url) {
//                    try! db.write {
//                        object.data = try? Data(contentsOf: url)
//                        db.add(object, update: .all)
//                    }
//                }
//            }
//        }
        
    }
    
    
    private init() {}
    
}

extension DB {
    
    static func checkRealm() {        
        do {
            let _ = try Realm()
        } catch {
            let url = Realm.Configuration.defaultConfiguration.fileURL
            guard let url = url else {
                Notifications.send(title: "База данных Realm", subtitle: "\(String(describing: url))")
                return
            }
            
            if (try? FileManager.default.removeItem(at: url)) == nil {
                Notifications.send(title: "База данных Realm", subtitle: "Изменилась структура данных, но не получилось удалить базу данных по \(url.description)")
            } else {
                Notifications.send(title: "База данных Realm", subtitle: "Файл базы данных realm был удален, так как изменилась структура данных")
            }
        }
    }
    
    static func deleteAll() {
        
        do {
            if let realm = try? Realm() {
                try realm.write {
                    realm.deleteAll()
                    Notifications.send(title: "База данных Realm", subtitle: "Успешно удалена")
                }
            }
        } catch {
            Notifications.send(title: "База данных Realm", subtitle: "\(error)")
        }
    }
    
}
