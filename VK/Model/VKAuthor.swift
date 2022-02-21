//
//  VKAuthor.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import UIKit

protocol VKAuthor: AnyObject {

    var id: Int { get }
    var name: String { get }
    var photo: String? { get }
    
    var image: UIImage? { get }
    
}
