//
//  VKAuthor.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import RealmSwift

protocol VKAuthor {

    var _id: Int { get }
    var _name: String { get }
    var _photoUrl: String { get }
    
    var _photo: Data? { get }
    
}
