//
//  Users.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation


class VKUser: VKAuthor {
    
    var id: Int
    var firstName: String
    var lastName: String

    var isFriend: Bool
    
    var name: String {
        "\(firstName) \(lastName)"
    }
    
    var photoUrl: String
    var photo: Data? = nil
    
    static func emptyUser() -> VKUser {
        VKUser(id: 0, firstName: "<Пользователь не найден>", lastName: "", isFriend: false)
    }
    
    
    init(id: Int, firstName: String, lastName: String, isFriend: Bool, photoUrl: String = "") {
        
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isFriend = isFriend
        self.photoUrl = photoUrl
        
        DispatchQueue.global().async {
            if let url = URL(string: photoUrl) {
                self.photo = try? Data(contentsOf: url)
            }
        }
        
    }
    
}
