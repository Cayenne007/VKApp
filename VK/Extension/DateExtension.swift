//
//  DateExtension.swift
//  VK
//
//  Created by Vladlen Sukhov on 18.02.2022.
//

import Foundation
import SwiftDate

extension Date {
    var title: String {
        self.toFormat("EEEE, dd.MM.yyyy", locale: Locales.russian)
    }
}
