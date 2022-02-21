//
//  VKPhoto.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import Foundation
import UIKit

class VKPhoto {
    var id: Int
    var ownerId: Int
    var text: String
    var url: String?
    
    var image: UIImage = UIImage(systemName: "photo")!
    
    init(id: Int, ownerId: Int, text: String, url: String?) {
        self.id = id
        self.ownerId = ownerId
        self.text = text
        self.url = url
    }
}
