//
//  Friends.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import UIKit
import RealmSwift


class FriendsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var users: Results<VKUser>!
    var myFriends: Results<VKUser> {
        users.filter("isFriend = true").sorted(byKeyPath: "firstName")
    }
    var token: NotificationToken?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Друзья"
        
        tableView.addRefreshControl()
        Notifications.addObserver{
            self.tableView.reloadData()
        }
        
        guard let realm = try? Realm() else {
            users = nil
            return
        }
        
        users = realm.objects(VKUser.self)
        token = users.observe{ [weak self] changes in
            switch changes {
                
            case .initial(_):
                self?.tableView.reloadData()
            //case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
            case .update(_, deletions: _, insertions: _, modifications: _):
                self?.tableView.reloadData()
//                self?.tableView.performBatchUpdates{
//                    self?.tableView.deleteRows(at: deletions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
//                    self?.tableView.insertRows(at: insertions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
//                    self?.tableView.reloadRows(at: modifications.map{IndexPath(row: $0, section: 0)}, with: .automatic)
//                }
            case .error(let error):
                print(error)
            }
        }

        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Notifications.removeObserver(object: self)
    }
}


extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = myFriends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = user.name
        
        if let photo = user.photo {
            content.image = UIImage(data: photo)
        } else {
            content.image = UIImage(systemName: "photo")
        }
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = myFriends[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: PhotosViewController.className) as! PhotosViewController
        vc.ownerId = friend.id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
