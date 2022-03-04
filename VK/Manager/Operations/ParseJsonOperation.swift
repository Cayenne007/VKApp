//
//  ReponseJsonOperation.swift
//  VK
//
//  Created by Vladlen Sukhov on 25.02.2022.
//

import Foundation

class ParseJsonOperation: AsyncOperation {
    
    private let dataType: DataType
    
    var friends: [JsonUser] = []
    var newsfeed: [JsonNewsfeedResponse.JsonNewsfeed] = []
    var groups: [JsonGroup] = []
    
    override func main() {
        guard let getDataOperation = dependencies.first as? GetDataOperation,
        let data = getDataOperation.data else {
            state = .finished
            return
        }
        
        do {
            switch dataType {
            case .friends:
                let result = try JSONDecoder().decode(JsonVkObjectSource.ResponseWithItems<[JsonUser]>.self, from: data)
                friends = result.response.items
                state = .finished
            }
        } catch {            
            Notifications.send(title: "Загрузка друзей", subtitle: "\(error)")
            state = .finished
        }
        
    }
    
    init(_ dataType: DataType) {
        self.dataType = dataType
    }
    
    enum DataType {
        case friends
    }
    
    
    
    
}
