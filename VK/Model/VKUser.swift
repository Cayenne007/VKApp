//
//  Users.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import RealmSwift


class VKUser: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var firstName = ""
    @objc dynamic var lastName = ""

    @objc dynamic var isFriend = false
    
    dynamic var name: String {
        "\(firstName) \(lastName)"
    }
    
    @objc dynamic var photoUrl = ""
    
    
    override class func primaryKey() -> String? {
        "id"
    }
    
    
    convenience init(id: Int, firstName: String, lastName: String, isFriend: Bool, photoUrl: String = "") {
        self.init()
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isFriend = isFriend
        self.photoUrl = photoUrl
        
    }
    
    
}

