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
            case .update(_, let deletions, let insertions, let modifications):
                self?.tableView.performBatchUpdates{
                    self?.tableView.insertRows(at: insertions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                    self?.tableView.reloadRows(at: modifications.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                    self?.tableView.deleteRows(at: deletions.map{IndexPath(row: $0, section: 0)}, with: .automatic)
                }            case .error(let error):
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let group = myGroups[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        
        let image = photoService.photo(at: indexPath, url: group.photoUrl)
        cell.addTextWithImage(image: image, text: group.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: PhotosViewController.className) as! PhotosViewController
        vc.ownerId = -myGroups[indexPath.row].id
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
