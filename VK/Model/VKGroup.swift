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
    @objc dynamic var photo: Data? = nil
    
   
    
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
    
    
    //для совместимости
    var _id: Int { id }
    var _name: String { name }
    var _photoUrl: String { photoUrl }
    var _photo: Data? { photo }
    
    
}


//class VKGroup: VKAuthor {
//
//    let id: Int
//    let name: String
//    let isMember: Bool
//
//    let photoUrl: String
//    var photo: Data? = nil
//
//    static func emptyGroup() -> VKGroup {
//        VKGroup(id: 0, name: "<Группа не найдена>", isMember: false)
//    }
//
//    init(id: Int, name: String, isMember: Bool, photoUrl: String = "") {
//
//        self.id = id
//        self.name = name
//        self.photoUrl = photoUrl
//        self.isMember = isMember
//
//        DispatchQueue.global().async {
//            if let url = URL(string: photoUrl) {
//                self.photo = try? Data(contentsOf: url)
//            }
//        }
//    }
//
//}
