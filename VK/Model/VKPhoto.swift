//
//  VKPhoto.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation
import RealmSwift


class VKPhoto: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var ownerId = 0
    @objc dynamic var text = ""
    @objc dynamic var url = ""
    
    
    convenience init(id: Int, ownerId: Int, text: String, url: String) {
        self.init()
        
        self.id = id
        self.ownerId = ownerId
        self.text = text
        self.url = url
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
    
}
