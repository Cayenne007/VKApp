//
//  Group.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import RealmSwift


class VKGroup: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var isMember = false
    
    @objc dynamic var photoUrl = ""
   
    
    convenience init(id: Int, name: String, isMember: Bool, photoUrl: String = "") {
        self.init()
        self.id = id
        self.name = name
        self.photoUrl = photoUrl
        self.isMember = isMember
    }
    
    override class func primaryKey() -> String? {
        "id"
    }
    
}
