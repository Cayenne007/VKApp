//
//  Firebase.swift
//  VK
//
//  Created by Vladlen Sukhov on 11.03.2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import RealmSwift


struct Authorization {
    static func logIn() {
        Auth.auth().signInAnonymously { _, _ in }
    }
}

struct CloudDB {
    
    private let db = Firestore.firestore()
    private let realm = try! Realm()
    
    static let vk = CloudDB()
    
    
    func importData() {
        
        realm.objects(VKUser.self).forEach { object in
            
            db.collection("Friends").document(object.id.str).setData([
                "firstName" : object.firstName,
                "lastName" : object.lastName,
                "photoUrl" : object.photoUrl
            
            ]){ err in
                if let err = err {
                    print(err)
                }
            }

            
        }
        
        realm.objects(VKGroup.self).forEach { object in
            
            db.collection("Groups").document(object.id.str).setData([
                "name" : object.name,
                "photoUrl" : object.photoUrl
            
            ]){ err in
                if let err = err {
                    print(err)
                }
            }

            
        }
        
        
        realm.objects(VKNews.self).forEach { object in
            
            db.collection("Newsfeed").document(object.id.str).setData([
                "sourceId" : object.sourceId,
                "date" : object.date,
                "text" : object.text,
                "postType" : object.postType,
                "photoUrls" : Array(object.photoUrls)
            
            ]){ err in
                if let err = err {
                    print(err)
                }
            }

            
        }

        
        
    }
    
    
    private init() {}
    
}
