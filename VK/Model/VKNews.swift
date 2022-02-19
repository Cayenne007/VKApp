//
//  VKNews.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import UIKit

struct VKNews{
    
    var author: VKAuthor
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
    
}
