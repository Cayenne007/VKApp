//
//  Newsfeed.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit

class NewsfeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var list: [VKNews] {
        DB.vk.newsfeed
    }
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Новости"
        
        tableView.addRefreshControl()
        Notifications.addObserver{
            self.tableView.reloadData()
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
        list.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list[section].photos.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let newsfeed = tableView.dequeueReusableCell(withIdentifier: "body", for: indexPath)
            var content = newsfeed.defaultContentConfiguration()
            
            let item = list[indexPath.section]
            content.text = item.text
            
            newsfeed.contentConfiguration = content
            
            return newsfeed
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "photo", for: indexPath) as! NewsfeedPhotosCell
            let item = list[indexPath.section]
            cell.item = item
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
        let item = list[section]
        view.titleLabel.text = item.author.name
        view.subTitleLabel.text = item.date.title
        view.logo.image = item.author.image

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let item = list[section]
        let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as! NewsfeedFooter
        footer.chatCount.text = item.comments.str
        footer.heartCount.text = item.likes.str
        footer.viewCount.text = item.views.str
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

