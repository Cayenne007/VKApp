//
//  RealmHelpers.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation
import RealmSwift
import PromiseKit


struct PromiseRealm {
    
    static func addGroups(_ items: [JsonGroup]) -> Promise<[VKGroup]> {
        
        Promise<[VKGroup]> { seal in
            let db = try! Realm()
            let objectIds = Array(db.objects(VKGroup.self).map{$0.id})
            
            let objects = items.filter{!objectIds.contains($0.id)}
                .map { json in
                    
                    VKGroup(id: json.id,
                            name: json.name,
                            isMember: json.isMember?.bool ?? false,
                            photoUrl: json.photo100
                    )
                }
            
            if objects.count > 0 {
                do {
                    try db.write {
                        db.add(objects, update: .all)
                    }
                } catch {
                    return seal.reject(error)
                }
            }
            
            return seal.fulfill(objects)
                        
        }
            
    }
    
//    static func loadGroupImages() -> Promise<Bool> {
//        Promise<Bool>{ seal in
//            let db = try Realm()
//            db.objects(VKGroup.self).filter{!$0.photoUrl.isEmpty && $0.photo == nil}.forEach{ object in
//                if let url = URL(string: object.photoUrl) {
//                    try? db.write {
//                        object.photo = try? Data(contentsOf: url)
//                        db.add(object, update: .all)
//                    }
//                }
//            }
//            return seal.fulfill(true)
//        }
//    }
    
}
