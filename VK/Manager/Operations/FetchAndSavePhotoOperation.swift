//
//  FetchAndSavePhotoOperation.swift
//  VK
//
//  Created by Vladlen Sukhov on 25.02.2022.
//

import Foundation
import RealmSwift

class FetchAndSavePhotoOperation: AsyncOperation {
    
    override func main() {        
        fetchUserPhotos()
    }
    
}

extension FetchAndSavePhotoOperation {
    
    func fetchUserPhotos() {
        
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
