//
//  Groups.swift
//  VK
//
//  Created by Vladlen Sukhov on 20.02.2022.
//

import UIKit
import RealmSwift


class GroupsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var groups: Results<VKGroup>!
    private var myGroups: Results<VKGroup> {
        groups.filter("isMember = true").sorted(byKeyPath: "name")
    }
    private var token: NotificationToken?
    
    private var photoService: PhotoService!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Группы"
        
        tableView.addRefreshControl()
        photoService = PhotoService(container: tableView)
        
        guard let realm = try? Realm() else {
            groups = nil
            return
        }
        
        groups = realm.objects(VKGroup.self)
        token = groups.observe{ [weak self] changes in
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


extension GroupsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let group = myGroups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        content.text = group.name
        content.image = photoService.photo(at: indexPath, url: group.photoUrl)
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PhotosViewController.className) as! PhotosViewController
        vc.ownerId = -myGroups[indexPath.row].id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
