//
//  Newsfeed.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit
import RealmSwift


class NewsfeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let realm = try! Realm()
    private var newsfeed: Results<VKNews>!
    private var token: NotificationToken?
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Новости"
        
        tableView.addRefreshControl()
        
        newsfeed = realm.objects(VKNews.self)        
        token = newsfeed.observe{ [weak self] changes in
            switch changes {
                
            case .initial(_):
                self?.tableView.reloadData()
            //case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
            case .update(_, deletions: _, insertions: _, modifications: _):
                self?.tableView.reloadData()
                
//                self?.tableView.performBatchUpdates{
//                    self?.tableView.deleteRows(at: deletions.map{IndexPath(row: 0, section: $0)}, with: .automatic)
//                    self?.tableView.insertRows(at: insertions.map{IndexPath(row: 0, section: $0)}, with: .automatic)
//                    self?.tableView.reloadRows(at: modifications.map{IndexPath(row: 0, section: $0)}, with: .automatic)
//                }
            case .error(let error):
                print(error)
            }
        }

        
        tableView.register(UINib(nibName: "NewsfeedHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UINib(nibName: "NewsfeedFooter", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "footer")
        tableView.register(UINib(nibName: "NewsfeedPhoto", bundle: nil),
                           forCellReuseIdentifier: "photo")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "body")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        checkAuthorization()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Notifications.removeObserver(object: self)
    }
    
}


extension NewsfeedViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        newsfeed.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        newsfeed[section].photoUrls.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "body", for: indexPath)
            var content = cell.defaultContentConfiguration()
            
            let item = newsfeed[indexPath.section]
            content.text = item.text
            
            cell.contentConfiguration = content
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photo", for: indexPath) as! NewsfeedPhotosCell
            let item = newsfeed[indexPath.section]
            cell.newsfeedId = item.id
            //NotificationCenter.default.addObserver(forName: Notification.Name("update"), object: item, queue: .main) { _ in
                cell.collectionView.reloadData()
            //}
            
            return cell
        }
    }
    
}

extension NewsfeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return 200//tableView.frame.height * 0.5
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                      "header") as! NewsfeedHeader
        let item = newsfeed[section]
        
        if item.sourceId > 0, let author = realm.object(ofType: VKUser.self, forPrimaryKey: item.sourceId) {
            view.titleLabel.text = author._name
            if let photo = author.photo {
                view.logo.image = UIImage(data: photo)
            }
        } else if let author = realm.object(ofType: VKGroup.self, forPrimaryKey: -item.sourceId) {
            view.titleLabel.text = author._name
            if let photo = author.photo {
                view.logo.image = UIImage(data: photo)
            }
        }
        
        view.subTitleLabel.text = item.date.title
        
        if view.logo.image == nil {
            view.logo.image = UIImage(systemName: "photo")
        }

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let item = newsfeed[section]
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as! NewsfeedFooter
        footer.chatCount.text = item.comments.str
        footer.heartCount.text = item.likes.str
        footer.viewCount.text = item.views.str
        footer.url = item.url
        footer.isUserInteractionEnabled = true
        return footer
    }
    
}

extension NewsfeedViewController {
    
    func checkAuthorization() {
        
        if AppSettings.token.isEmpty {
            performSegue(withIdentifier: LoginViewController.className, sender: nil)
        }
        
    }
    
}

