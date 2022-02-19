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
    var groups: [VKGroup] = []
    var newsfeed: [VKNews] = []
    
    static func getAuthor(id: Int) -> VKAuthor {
        if id > 0 {
            return DB.vk.users.first(where: {$0.id == id}) ?? VKUser(id: 0, firstName: "<Пользователь не найден>", lastName: "", photo: nil)
        } else {
            return DB.vk.groups.first(where: {$0.id == -id}) ?? VKGroup(id: 0, name: "<Группа не найдена>", photo: nil)
        }
    }

    private init() {}
    
}
