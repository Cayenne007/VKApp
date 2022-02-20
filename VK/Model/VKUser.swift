//
//  Users.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import UIKit

class VKUser: VKAuthor {
    
    var id: Int
    var firstName: String
    var lastName: String
    
    var photo: String?
    var isFriend: Bool
    
    var name: String {
        "\(firstName) \(lastName)"
    }
    
    var image: UIImage?
    
    static func emptyUser() -> VKUser {
        VKUser(id: 0, firstName: "<Пользователь не найден>", lastName: "", isFriend: false, photo: nil)
    }
    
    
    init(id: Int, firstName: String, lastName: String, isFriend: Bool, photo: String?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isFriend = isFriend
        self.photo = photo
        self.image = UIImage(systemName: "photo")
        
        DispatchQueue.global().async {
            if let photo = photo,
               let data = try? Data(contentsOf: photo.url),
                let image = UIImage(data: data){
                
                self.image = image
                
            }
        }
        
    }
    
}
