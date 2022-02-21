//
//  Friends.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import UIKit


class FriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Друзья"
        
        let notification = NSNotification.Name("update")
        NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { _ in
            self.tableView.reloadData()
        }
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
    
}


extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        DB.vk.friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = DB.vk.friends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = user.name
        content.image = user.image
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = DB.vk.friends[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: FriendPhotoViewController.className) as! FriendPhotoViewController
        vc.owner = friend
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
