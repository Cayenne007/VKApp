// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jSONFriendsData = try? newJSONDecoder().decode(JSONFriendsData.self, from: jsonData)

import Foundation

// MARK: - JSONFriendsData
struct JsonFriendsData: Codable {
    
    var response: JsonFriendsResponse

    init(response: JsonFriendsResponse) {
        self.response = response
    }
}

// MARK: - Response
struct JsonFriendsResponse: Codable {
    
    
    let count: Int
    var items: [JsonFriend]

    init(count: Int, items: [JsonFriend]) {
        self.count = count
        self.items = items
    }
}

// MARK: - Item
struct JsonFriend: Encodable,Decodable {
    let id: Int
    let firstName, lastName: String
    let isClosed: Bool?
    let photo100: String
    let online: Int
    let nickname: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case isClosed = "is_closed"
        case photo100 = "photo_100"
        case online, nickname
        case status
    }

    init(id: Int, firstName: String, lastName: String, isClosed: Bool, photo100: String, online: Int, nickname: String, status: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.isClosed = isClosed
        self.photo100 = photo100
        self.online = online
        self.nickname = nickname
        self.status = status
    }
}


