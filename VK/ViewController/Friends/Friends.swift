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
    
    private var users: Results<VKUser>!
    private var myFriends: Results<VKUser> {
        users.filter("isFriend = true").sorted(byKeyPath: "firstName")
    }
    private var token: NotificationToken?
    
    private var photoService: PhotoService!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Друзья"
        
        tableView.addRefreshControl()
        photoService = PhotoService(container: tableView)
        
        guard let realm = try? Realm() else {
            users = nil
            return
        }
        
        users = realm.objects(VKUser.self)
        token = users.observe{ [weak self] changes in
            switch changes {
                
            case .initial(_):
                self?.tableView.reloadData()
            case .update(_, deletions: _, insertions: _, modifications: _):
                self?.tableView.reloadData()
            case .error(let error):
                print(error)
            }
        }

        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        
        
        Notifications.addObserver {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Notifications.removeObserver(object: self)
    }
}


extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let user = myFriends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        
        let image = photoService.photo(at: indexPath, url: user.photoUrl)
        cell.addTextWithImage(image: image, text: user.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = myFriends[indexPath.row]
        let vc = storyboard?.instantiateViewController(withIdentifier: PhotosViewController.className) as! PhotosViewController
        vc.ownerId = friend.id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


