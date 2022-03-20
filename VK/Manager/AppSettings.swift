//
//  AppSettings.swift
//  VK
//
//  Created by Vladlen Sukhov on 18.02.2022.
//

import Foundation

struct AppSettings {
    
    static var token: String {
        get{ UserDefaults.standard.string(forKey: "token") ?? "" }
        set{ UserDefaults.standard.set(newValue, forKey: "token") }
    }
    
    static var userId: String {
        get{ UserDefaults.standard.string(forKey: "userId") ?? "" }
        set{ UserDefaults.standard.set(newValue, forKey: "userId") }
    }
 
}
