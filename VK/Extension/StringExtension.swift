//
//  StringExtension.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation

extension String {
    
    var url: URL {
        URL(string: self)!
    }
    
}
