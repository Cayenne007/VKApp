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
        VK.api.fetchData()
        refreshControl?.endRefreshing()
    }
}
