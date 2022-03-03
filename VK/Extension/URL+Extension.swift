//
//  URLExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 22.02.2022.
//

import Foundation


extension URL {
    func withQueryItem(key: String, value: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        
        if let items = components?.queryItems {
            components?.queryItems = items + [
                URLQueryItem(name: key, value: value),
            ]
        } else {
            components?.queryItems = [
                URLQueryItem(name: key, value: value),
            ]
        }
        
        
        return components?.url ?? self
    }
}
