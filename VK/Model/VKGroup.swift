//
//  Group.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation


class VKGroup: VKAuthor {
    
    let id: Int
    let name: String
    let isMember: Bool
    
    let photoUrl: String
    var photo: Data? = nil
    
    static func emptyGroup() -> VKGroup {
        VKGroup(id: 0, name: "<Группа не найдена>", isMember: false)
    }
    
    init(id: Int, name: String, isMember: Bool, photoUrl: String = "") {
    
        self.id = id
        self.name = name
        self.photoUrl = photoUrl
        self.isMember = isMember
        
        DispatchQueue.global().async {
            if let url = URL(string: photoUrl) {
                self.photo = try? Data(contentsOf: url)                
            }
        }
    }
    
}
