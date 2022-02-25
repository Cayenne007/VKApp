//
//  VKNews.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation


class VKNews{
    
    var sourceId: Int
    var date: Date
    var id: Int
    var text = ""
    
    var likes = 0
    var userLikes = 0
    
    var comments = 0
    
    var reposts = 0
    var userReposts = 0
    
    var views = 0
    
    var photoUrls: [String] = []
    var photos: [Data?] = []
    
    var author: VKAuthor {
        DB.getAuthor(id: sourceId)
    }
    
    var url: String
    
    init(sourceId: Int, date: Date, id: Int, text: String, likes: Int, userLikes: Int, comments: Int, reposts: Int, userReposts: Int, views: Int, photoUrls: [String], url: String) {
        
        self.sourceId = sourceId
        self.date = date
        self.id = id
        self.text = text
        self.likes = likes
        self.userLikes = userLikes
        self.comments = comments
        self.reposts = reposts
        self.userReposts = userReposts
        self.views = views
        self.photoUrls = photoUrls
        self.url = url
        
    }
           
    
}
