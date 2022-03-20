//
//  SaveToRealmOperation.swift
//  VK
//
//  Created by Vladlen Sukhov on 25.02.2022.
//

import Foundation
import RealmSwift


class SaveToRealmOperation: AsyncOperation {
    
    override func main() {
        guard let parseJsonOperation = dependencies.first as? ParseJsonOperation else {
            state = .finished
            return
        }
        
        addUser(parseJsonOperation.friends)
        state = .finished
        
    }
    
}

extension SaveToRealmOperation {
    
    private func addUser(_ items: [JsonUser]) {
        
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
        
    }

    
}
