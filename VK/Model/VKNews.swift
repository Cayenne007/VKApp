//
//  VKNews.swift
//  VkApp
//
//  Created by Vladlen Sukhov on 17.02.2022.
//

import Foundation
import RealmSwift


class VKNews: Object {

    @objc dynamic var sourceId = 0
    @objc dynamic var date = Date()
    @objc dynamic var id = 0
    @objc dynamic var text = ""

    @objc dynamic var likes = 0
    @objc dynamic var userLikes = 0

    @objc dynamic var comments = 0

    @objc dynamic var reposts = 0
    @objc dynamic var userReposts = 0

    @objc dynamic var views = 0

    var photoUrls = List<String>()


    @objc dynamic var url = ""
    @objc dynamic var postType = ""

    override class func primaryKey() -> String? {
        "id"
    }


    convenience init(sourceId: Int, date: Date, id: Int, text: String, likes: Int, userLikes: Int, comments: Int, reposts: Int, userReposts: Int, views: Int, photoUrls: [String], url: String, postType: String) {

        self.init()

        self.sourceId = sourceId
        self.date = date
        self.id = id
        self.text = text
        self.likes = likes
        self.userLikes = userLikes
        self.comments = comments
        self.reposts = reposts
        self.userReposts = userReposts
        self.views = views
        self.photoUrls = photoUrls.reduce(into: List<String>(), { $0.append($1) })
        self.url = url
        self.postType = postType

    }
}
