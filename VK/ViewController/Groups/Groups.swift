//
//  Groups.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import UIKit


class GroupsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Группы"
        
        let notification = NSNotification.Name("update")
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { _ in
            self.tableView.reloadData()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
    
}


extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DB.vk.groups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let group = DB.vk.groups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = group.name
        content.image = group.image
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    
}
