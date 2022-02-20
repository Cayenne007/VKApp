//
//  VKNews.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import UIKit

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
    
    var photos: [String] = []
    
    var photo: String {
        photos.first ?? ""
    }
    
    var images: [UIImage] = []
    
    var author: VKAuthor {
        DB.getAuthor(id: sourceId)
    }
    
    init(sourceId: Int, date: Date, id: Int, text: String, likes: Int, userLikes: Int, comments: Int, reposts: Int, userReposts: Int, views: Int, photos: [String]) {
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
        self.photos = photos
        
        DispatchQueue.global().async {
            photos.forEach{ url in
                if let url = URL(string: url),
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data){
                
                    self.images.append(image)
                } else {
                    self.images.append(UIImage(systemName: "photo")!)
                }
            }
        }
        
    }
           
    
}
