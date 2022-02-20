//
//  IntExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 19.02.2022.
//

import Foundation

extension Int {
    var str: String {
        "\(self)"
    }
    
    var bool: Bool {
        switch self {
        case 0:
            return false
        case 1:
            return true
        default:
            return false
        }
    }
}
