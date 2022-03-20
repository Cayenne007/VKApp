//
//  UIViewController+Extansion.swift
//  VK
//
//  Created by Vladlen Sukhov on 11.03.2022.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, subtitle: String = "") {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
}
