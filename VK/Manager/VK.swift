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
        
        let dispatchGroup = DispatchGroup()
              
        PromiseAPI.vk.fetchGroups()
        //fetchObjectsById(path: .groups, group: dispatchGroup)
        fetchFriends(group: dispatchGroup)
        fetchNewsfeed(group: dispatchGroup)
        
    }
    
    func fetchPhotos(id: Int) {
        
        let url = URLS.buildUrl(.photos(ownerId: id))
        URLSession.shared.json(url,
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

        let url = path.url
        URLSession.shared.json(url,
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
    
    private func fetchFriends(group: DispatchGroup) {
        
        let url = URLS.buildUrl(.friends)
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
        
//        URLSession.shared.json(url,
//                               source: .responseItems,
//                               decode: [JsonUser].self) { result in
//
//            switch result {
//            case .failure(let error):
//                print(error)
//            case .success(let result):
//                addUsers(items: result, group: group)
//            }
//        }
        
    }
    
}


extension VK {
    
    private func fetchUsersByIds(ids: String, group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.userByIds(ids: ids))
        
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
        
        let url = URLS.buildUrl(.groupByIds(ids: ids))
        URLSession.shared.json(url,
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
    
    private func fetchNewsfeed(group: DispatchGroup) {
        
        group.enter()
        
        let url = URLS.buildUrl(.news)
        
        URLSession.shared.json(url,
                               source: .response,
                               decode: JsonNewsfeedResponse.self) { result in
            
            switch result {
            case .failure(let error):                
                Notifications.send(title: "Загрузка новостей", subtitle: "\(error)")
            case .success(let result):
                addUsers(items: result.profiles, group: group)
                addGroups(items: result.groups, group: group)
                addNewsfeed(items: result.items, url: url)
                group.leave()
                
            }
        }
        
    }
    
    private func addNewsfeed(items: [JsonNewsfeedResponse.JsonNewsfeed], url: URL) {
        let items = items.filter{ item in
            !(item.text ?? "").isEmpty
        }
        DB.vk.addNewsfeed(items, url: url)
    }
}




