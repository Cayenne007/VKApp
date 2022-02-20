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
    var friends: [VKUser] { users.filter{$0.isFriend} }
    var groups: [VKGroup] = []
    var newsfeed: [VKNews] = []
    
    static func getAuthor(id: Int) -> VKAuthor {
        if id > 0 {
            return DB.vk.users.first(where: {$0.id == id}) ?? VKUser.emptyUser()
        } else {
            return DB.vk.groups.first(where: {$0.id == -id}) ?? VKGroup.emptyGroup()
        }
    }

    private init() {}
    
}
