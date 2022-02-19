//
//  Users.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation

struct VKUser: VKAuthor {
    
    var id: Int
    var firstName: String
    var lastName: String
    
    var photo: String?
    
    var name: String {
        "\(firstName) \(lastName)"
    }
    
}
