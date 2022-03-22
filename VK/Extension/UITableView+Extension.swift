//
//  UITableView.swift
//  VK
//
//  Created by Vladlen Sukhov on 21.02.2022.
//

import Foundation
import UIKit

extension UITableView {
    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
    }
    @objc private func fetchData() {
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Загрузка ...")
        VK.api.fetchData()
        self.refreshControl?.endRefreshing()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "")
        
    }
}
