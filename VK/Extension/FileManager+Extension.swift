//
//  FileManager.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation

extension FileManager {
    
    static var cacheDirectory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
    
    static var documentsDirectory: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
}
