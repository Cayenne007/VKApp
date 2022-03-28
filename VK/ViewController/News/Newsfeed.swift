//
//  Newsfeed.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import UIKit
import RealmSwift
import FirebaseAnalytics


class NewsfeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var isLoading = false
    private var nextFrom: String? = ""
    
    private let realm = try! Realm()
    private var newsfeed: Results<VKNews>!
    private var token: NotificationToken?
    
    private var photoService: PhotoService!
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Новости"
        
        tableView.addRefreshControl()
        photoService = PhotoService(container: tableView)
        
        Notifications.addObserver {
            self.tableView.reloadData()
        }
        
        newsfeed = realm.objects(VKNews.self).sorted(byKeyPath: "date", ascending: false)
        token = newsfeed.observe{ [weak self] changes in
            switch changes {
                
            case .initial(_):
                self?.tableView.reloadData()            
            case .update(_, let deletions, let insertions, let modifications):
                
                self?.tableView.performBatchUpdates{
                    self?.tableView.insertSections(insertions.reduce(into: IndexSet(), {$0.insert($1)}), with: .automatic)
                    self?.tableView.reloadSections(modifications.reduce(into: IndexSet(), {$0.insert($1)}), with: .automatic)
                    self?.tableView.deleteSections(deletions.reduce(into: IndexSet(), {$0.insert($1)}), with: .automatic)
                }
                
            case .error(let error):
                print(error)
            }
        }

    
        tableView.register(UINib(nibName: "NewsfeedHeader", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(UINib(nibName: "NewsfeedFooter", bundle: nil),
                           forHeaderFooterViewReuseIdentifier: "footer")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "body")
        
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "vk_app_newsscreen"
        ])
        
        isLoading = true
        VK.api.fetchNewsfeed { [weak self] nextFrom in
            self?.nextFrom = nextFrom
            self?.isLoading = false
        }
        
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
        
        let item = newsfeed[indexPath.section]
        if indexPath.row == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "photo", for: indexPath) as! NewsfeedPhotosCell
            cell.photoUrls = Array(item.photoUrls)
            cell.collectionView.reloadData()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "body", for: indexPath)
            let item = newsfeed[indexPath.section]
            
            var content = cell.defaultContentConfiguration()
            content.text = item.text
            cell.contentConfiguration = content
            
            //cell.backgroundColor = .systemBackground  не работает
            
            return cell

        }
        
    }
    
}

extension NewsfeedViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = newsfeed[indexPath.row]
//        section.photoUrls.forEach{url in
//            let image = photoService.photo(at: <#T##IndexPath#>, url: <#T##String#>)
//        }
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
            view.titleLabel.text = author.name
            view.logo.image = photoService.photo(at: IndexPath(item: 0, section: section), url: author.photoUrl)
        } else if let author = realm.object(ofType: VKGroup.self, forPrimaryKey: -item.sourceId) {
            view.titleLabel.text = author.name
            view.logo.image = photoService.photo(at: IndexPath(item: 0, section: section), url: author.photoUrl)
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // here will be infinity newsfeed
    }
    
}

extension NewsfeedViewController {
    
    func checkAuthorization() {
        
        if AppSettings.token.isEmpty {
            performSegue(withIdentifier: LoginViewController.className, sender: nil)
        }
        
    }
    
}




extension NewsfeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        
        guard let maxSection = indexPaths.map({ $0.section }).max(),
              maxSection > newsfeed.count - 3, !isLoading else { return }

        isLoading = true
        
        VK.api.fetchNewsfeed(nextFrom: nextFrom) { [weak self] nextFrom in
            self?.nextFrom = nextFrom
            self?.isLoading = false
        }
        
    }
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}
