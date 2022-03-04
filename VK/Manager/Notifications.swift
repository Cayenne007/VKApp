//
//  Notification.swift
//  VK
//
//  Created by Vladlen Sukhov on 21.02.2022.
//

import Foundation
import UserNotifications


class Notifications: NSObject {
   
    static var shared = Notifications()
    private override init() {}
    
    
    static func send(title: String, subtitle: String = "") {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = subtitle

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
        
        print(title)
        print(subtitle)
    }
    func authorize() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.requestAuthorization(options: [.sound, .alert, .badge]) { _, _ in }
        notificationCenter.delegate = self
    }
}

extension Notifications: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner,.sound])
    }
    
}

extension Notifications {
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
