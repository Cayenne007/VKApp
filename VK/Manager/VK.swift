//
//  VK.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 16.02.2022.
//

import Foundation


struct VK {
    
    static var api = VK()
    
    func fetchData() {
        
        guard !AppSettings.token.isEmpty else {
            return
        }
        
        PromiseAPI.vk.fetchGroups()
        fetchFriends()
        
    }
    
    func fetchPhotos(id: Int) {
                
        URLSession.shared.json(URLS.photos(ownerId: id),
                               source: .responseItems,
                               decode: [JsonPhoto].self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let objects):
                addPhotos(items: objects)
            }
        }
        
    }
    
    private func fetchObjectsById(path: URLS, group: DispatchGroup) {
        
        group.enter()

        URLSession.shared.json(path,
                               source: .responseItems,
                               decode: [Int].self) { result in

            switch result {
            case .failure(let error):
                print(error)
            case .success(let ids):
                let ids = ids.map{String($0)}.joined(separator: ",")

                if path == .groups {
                    fetchGroupsByIds(ids: ids, group: group)
                } else if path == .friends {
                    fetchUsersByIds(ids: ids, group: group)
                }

                group.leave()
            }

        }
        
    }
    
    
    private init() {}
    
}


extension VK {
    
    private func addPhotos(items: [JsonPhoto]) {
        
        DB.vk.addPhotos(items: items)
        
    }
    
}

extension VK {
    
    private func fetchFriends() {
        
        let url = URLS.friends.url
        let operationQueue = OperationQueue()
        
        let getDataOperation = GetDataOperation(url: url)
        operationQueue.addOperation(getDataOperation)
        
        let parseJsonOperation = ParseJsonOperation(.friends)
        parseJsonOperation.addDependency(getDataOperation)
        operationQueue.addOperation(parseJsonOperation)
        
        let saveToRealmOperation = SaveToRealmOperation()
        saveToRealmOperation.addDependency(parseJsonOperation)
        operationQueue.addOperation(saveToRealmOperation)
        
        let fetchAndUpdatePhotoOperation = FetchAndSavePhotoOperation()
        fetchAndUpdatePhotoOperation.addDependency(saveToRealmOperation)
        operationQueue.addOperation(fetchAndUpdatePhotoOperation)
        
    }
    
}


extension VK {
    
    private func fetchUsersByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.userByIds(ids: ids)
        
        URLSession.shared.json(url,
                               source: .itself,
                               decode: [JsonUser].self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let json):
                addUsers(items: json, group: group)
                group.leave()
            }
        }
        
    }
    
    private func addUsers(items: [JsonUser], group: DispatchGroup) {
        DispatchQueue.global().async(group: group) {
            DB.vk.addUser(items)
        }
    }
    
    
}

extension VK {
    
    private func fetchGroupsByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        URLSession.shared.json(URLS.groupByIds(ids: ids),
                               source: .response,
                               decode: [JsonGroup].self) { result in
            
            switch result {
            case .failure(let error):
                print(error)
            case .success(let json):
                addGroups(items: json, group: group)
                group.leave()
            }
        }
        
    }
    
    private func addGroups(items: [JsonGroup], group: DispatchGroup) {        
        DB.vk.addGroup(items)
    }
    
}


extension VK {
    
    func fetchNewsfeed(nextFrom: String? = nil,_ completion: @escaping (String?)->()) {
        
        let group = DispatchGroup()
        
        group.enter()
        
        var url = URLS.news()
        
        if let nextFrom = nextFrom {
            url = URLS.news(queryItems: [
                URLQueryItem(name: "start_from", value: nextFrom)
            ])
        } else {
//            if let lastNewsDate = DB.newsfeedGetLastDate() {
//                url = URLS.news(queryItems: [
//                    URLQueryItem(name: "start_time", value: lastNewsDate.timeIntervalSince1970.str)
//                ])
//            }
        }
        
        URLSession.shared.json(url,
                               source: .response,
                               decode: JsonNewsfeedResponse.self) { result in
            
            switch result {
            case .failure(let error):                
                Notifications.send(title: "Загрузка новостей", subtitle: "\(error)")
            case .success(let result):
                addUsers(items: result.profiles, group: group)
                addGroups(items: result.groups, group: group)
                addNewsfeed(items: result.items, url: url.url, group: group)
                group.leave()
                
                group.notify(queue: .main) {
                    completion(result.nextFrom)
                }
                
            }
        }
        
    }
    
    private func addNewsfeed(items: [JsonNewsfeedResponse.JsonNewsfeed], url: URL, group: DispatchGroup) {
        let items = items.filter{ item in
            !(item.text ?? "").isEmpty
        }
        DispatchQueue.global().async(group: group) {
            DB.vk.addNewsfeed(items, url: url)
        }
    }
}




