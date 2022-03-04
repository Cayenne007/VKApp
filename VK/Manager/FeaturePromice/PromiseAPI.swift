//
//  PromiseAPI.swift
//  VK
//
//  Created by Vladlen Sukhov on 03.03.2022.
//

import Foundation
import PromiseKit
import Alamofire
import RealmSwift


class PromiseAPI {
    
    static var vk = PromiseAPI()
    
    lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        
        let sessionManager = Session(configuration: configuration, startRequestsImmediately: false)
        return sessionManager
    }()
    
    func fetchGroups() {
        
        typealias JsonItems = JsonVkObjectSource.ResponseWithItems<[Int]>
        typealias JsonReponse = JsonVkObjectSource.Response<[JsonGroup]>
        
        let promise: Promise<JsonItems> = session.requestJson(URLS.buildUrl(.groups))
        firstly{
            promise
        }
        .then{ result -> Promise<JsonReponse> in
            let ids = result.response.items.map{String($0)}.joined(separator: ",")
            let promise: Promise<JsonReponse> = self.session.requestJson(URLS.buildUrl(.groupByIds(ids: ids)))
            return promise
        }
        .then { groups -> Promise<[VKGroup]> in
            PromiseRealm.addGroups(groups.response)
        }
//        .then { groups -> Promise<Bool> in
//            PromiseRealm.loadGroupImages()
//        }
        .catch { error in
            Notifications.send(title: "Загрузка групп пользователя", subtitle: "\(error)")
        }
        .finally {}
            
    }
    
    private init() {}
    
}

