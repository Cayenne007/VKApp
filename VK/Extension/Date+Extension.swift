//
//  DateExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 18.02.2022.
//

import Foundation

extension Date {
    var title: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "EEEE, dd.MM.yyyy"
        dateFormatter.locale = Locale(identifier: "ru_Ru")
        return dateFormatter.string(from: self)
    }
}
