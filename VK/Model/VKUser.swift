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
    @objc dynamic var photo: Data? = nil
    
    
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
    
    //для совместимости
    var _id: Int { id }
    var _name: String { name }
    var _photoUrl: String { photoUrl }
    var _photo: Data? { photo }
    
}


//class VKUser: VKAuthor {
//
//    var id: Int
//    var firstName: String
//    var lastName: String
//
//    var isFriend: Bool
//
//    var name: String {
//        "\(firstName) \(lastName)"
//    }
//
//    var photoUrl: String
//    var photo: Data? = nil
//
//    static func emptyUser() -> VKUser {
//        VKUser(id: 0, firstName: "<Пользователь не найден>", lastName: "", isFriend: false)
//    }
//
//
//    init(id: Int, firstName: String, lastName: String, isFriend: Bool, photoUrl: String = "") {
//
//        self.id = id
//        self.firstName = firstName
//        self.lastName = lastName
//        self.isFriend = isFriend
//        self.photoUrl = photoUrl
//
//        DispatchQueue.global().async {
//            if let url = URL(string: photoUrl) {
//                self.photo = try? Data(contentsOf: url)
//            }
//        }
//
//    }
//
//
//    //для совместимости
//    var _id: Int { id }
//    var _name: String { name }
//    var _photoUrl: String { photoUrl }
//    var _photo: Data? { photo }
//
//}
