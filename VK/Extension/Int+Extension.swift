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
        self == 1 ? true : false
    }
    
}

extension Double {
    
    var str: String {
        String(Int(self))
    }
    
}
