//
//  Notification.swift
//  VK
//
//  Created by Vladlen Sukhov on 21.02.2022.
//

import Foundation

struct Notifications {
    static func addObserver(_ type: ObserverType = .update,_ completion: @escaping ()->()) {
        let notification = NSNotification.Name(type.rawValue)
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { _ in
            completion()
        }
    }
    static func postObserverNotification(_ type: ObserverType = .update) {
        let notification = NSNotification.Name(type.rawValue)
        NotificationCenter.default.post(name: notification, object: nil)
    }
    static func removeObserver(object: Any, _ type: ObserverType = .update) {
        let notification = NSNotification.Name(type.rawValue)
        NotificationCenter.default.removeObserver(object, name: notification, object: nil)
    }
    
    enum ObserverType: String {
        case update = "update"
        
    }
}
