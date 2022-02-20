//
//  Group.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import UIKit

class VKGroup: VKAuthor {
    
    let id: Int
    let name: String
    let photo: String?
    
    var image: UIImage?
    
    static func emptyGroup() -> VKGroup {
        VKGroup(id: 0, name: "<Группа не найдена>", photo: nil)
    }
    
    init(id: Int, name: String, photo: String?) {
        self.id = id
        self.name = name
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
