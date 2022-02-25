//
//  DB.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation

class DB {
    
    static var vk = DB()
    
    var users: [VKUser] = []
    var friends: [VKUser] { users.filter{ $0.isFriend} }
    var groups: [VKGroup] = []
    var myGroups: [VKGroup] { groups.filter{ $0.isMember} }
    var newsfeed: [VKNews] = []
    var photos: [VKPhoto] = []
    
    static func getAuthor(id: Int) -> VKAuthor {
        if id > 0 {
            return DB.vk.users.first(where: {$0.id == id}) ?? VKUser.emptyUser()
        } else {
            return DB.vk.groups.first(where: {$0.id == -id}) ?? VKGroup.emptyGroup()
        }
    }
    
    static func getPhotos(owner: VKAuthor?) -> [VKPhoto] {
        
        guard let id = owner?.id else {
            return []
        }
        let minus = (owner is VKGroup) ? (-1) : (1)
        
        return DB.vk.photos.filter{$0.ownerId == minus * id}
        
    }

    private init() {}
    
}
