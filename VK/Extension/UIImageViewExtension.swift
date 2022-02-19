//
//  UIImageExtension.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func loadImage(_ url: String?) {
        if let url = url {
            sd_setImage(with: URL(string: url), placeholderImage: UIImage(systemName: "photo"))
        } else {
            image = UIImage(systemName: "photo")
        }
    }
}
