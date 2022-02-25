// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let jSONNewsfeedData = try? newJSONDecoder().decode(JSONNewsfeedData.self, from: jsonData)

import Foundation


// MARK: - Response
struct JsonNewsfeedResponse: Codable {
    
    let items: [JsonNewsfeed]
    let profiles: [JsonUser]
    let groups: [JsonGroup]
    
    
    
    // MARK: - Item
    struct JsonNewsfeed: Codable {
        let sourceID, date: Int
        let postType: String?
        let text: String?
        let markedAsAds: Int?
        let attachments: [JsonItemAttachment]?
        let postSource: JsonPostSource?
        let comments: JsonComments?
        let likes: JsonLikes?
        let reposts: JsonReposts?
        let views: JsonViews?
        let isFavorite: Bool?
        let donut: JsonDonut?
        let shortTextRate: Double?
        let postID: Int?
        let type: String?
        let copyHistory: [JsonCopyHistory]?
        let carouselOffset, topicID: Int?
        
        enum CodingKeys: String, CodingKey {
            case sourceID = "source_id"
            case date
            case postType = "post_type"
            case text
            case markedAsAds = "marked_as_ads"
            case attachments
            case postSource = "post_source"
            case comments, likes, reposts, views
            case isFavorite = "is_favorite"
            case donut
            case shortTextRate = "short_text_rate"
            case postID = "post_id"
            case type
            case copyHistory = "copy_history"
            case carouselOffset = "carousel_offset"
            case topicID = "topic_id"
        }
        
    }
    
    // MARK: - ItemAttachment
    struct JsonItemAttachment: Codable {
        let type: String
        //let video: JsonPurpleVideo?
        let photo: JsonPhoto?
        //let link: JsonLink?
        //let audio: JsonAudio?
    }
    
    // MARK: - Audio
    struct JsonAudio: Codable {
        let artist: String
        let id, ownerID: Int
        let title: String
        let duration: Int
        let isExplicit, isFocusTrack: Bool
        let trackCode: String
        let url: String
        let date, noSearch: Int
        let mainArtists: [JsonMainArtist]
        let shortVideosAllowed, storiesAllowed, storiesCoverAllowed: Bool
        
        enum CodingKeys: String, CodingKey {
            case artist, id
            case ownerID = "owner_id"
            case title, duration
            case isExplicit = "is_explicit"
            case isFocusTrack = "is_focus_track"
            case trackCode = "track_code"
            case url, date
            case noSearch = "no_search"
            case mainArtists = "main_artists"
            case shortVideosAllowed = "short_videos_allowed"
            case storiesAllowed = "stories_allowed"
            case storiesCoverAllowed = "stories_cover_allowed"
        }
    }
    
    // MARK: - MainArtist
    struct JsonMainArtist: Codable {
        let name, domain, id: String
    }
    
    // MARK: - Link
    struct JsonLink: Codable {
        let url: String
        let title: String
        let caption: String?
        let linkDescription: String
        let photo: JsonPhoto
        let isFavorite: Bool
        let target: String?
        
        enum CodingKeys: String, CodingKey {
            case url, title, caption
            case linkDescription = "description"
            case photo
            case isFavorite = "is_favorite"
            case target
        }
    }
    
//    enum JsonAttachmentType: String, Codable {
//        case audio = "audio"
//        case link = "link"
//        case photo = "photo"
//        case video = "video"
//    }
    
    // MARK: - PurpleVideo
    struct JsonPurpleVideo: Codable {
        let accessKey: String
        let canComment, canLike, canRepost, canSubscribe: Int
        let canAddToFaves, canAdd: Int
        let comments: Int?
        let date: Int
        let videoDescription: String
        let duration: Int
        let image: [JsonSize]
        let firstFrame: [JsonSize]?
        let width, height: Int?
        let id, ownerID: Int
        let title: String
        let isFavorite: Bool
        let trackCode: String
        let type: String
        let views: Int
        let localViews: Int?
        let platform: String?
        let videoRepeat, albumID: Int?
        
        enum CodingKeys: String, CodingKey {
            case accessKey = "access_key"
            case canComment = "can_comment"
            case canLike = "can_like"
            case canRepost = "can_repost"
            case canSubscribe = "can_subscribe"
            case canAddToFaves = "can_add_to_faves"
            case canAdd = "can_add"
            case comments, date
            case videoDescription = "description"
            case duration, image
            case firstFrame = "first_frame"
            case width, height, id
            case ownerID = "owner_id"
            case title
            case isFavorite = "is_favorite"
            case trackCode = "track_code"
            case type, views
            case localViews = "local_views"
            case platform
            case videoRepeat = "repeat"
            case albumID = "album_id"
        }
    }
    
    // MARK: - Comments
    struct JsonComments: Codable {
        let canPost, count: Int
        let groupsCanPost: Bool?
        
        enum CodingKeys: String, CodingKey {
            case canPost = "can_post"
            case count
            case groupsCanPost = "groups_can_post"
        }
    }
    
    // MARK: - CopyHistory
    struct JsonCopyHistory: Codable {
        let id, ownerID, fromID, date: Int
        let postType, text: String
        let attachments: [JsonCopyHistoryAttachment]?
        let postSource: JsonPostSource
        
        enum CodingKeys: String, CodingKey {
            case id
            case ownerID = "owner_id"
            case fromID = "from_id"
            case date
            case postType = "post_type"
            case text, attachments
            case postSource = "post_source"
        }
    }
    
    // MARK: - CopyHistoryAttachment
    struct JsonCopyHistoryAttachment: Codable {
        let type: String
        let video: JsonFluffyVideo?
        let photo: JsonPhoto?
    }
    
    // MARK: - FluffyVideo
    struct JsonFluffyVideo: Codable {
        let accessKey: String
        let canComment, canLike, canRepost, canSubscribe: Int
        let canAddToFaves, canAdd, date: Int
        let comments: Int?
        let videoDescription: String?
        let duration: Int
        let image: [JsonSize]
        let id, ownerID: Int
        let title: String
        let isFavorite: Bool
        let trackCode: String
        let type: String
        let views: Int
        let localViews: Int?
        let platform: String?
        let firstFrame: [JsonSize]?
        let width, height, userID: Int?
        
        enum CodingKeys: String, CodingKey {
            case accessKey = "access_key"
            case canComment = "can_comment"
            case canLike = "can_like"
            case canRepost = "can_repost"
            case canSubscribe = "can_subscribe"
            case canAddToFaves = "can_add_to_faves"
            case canAdd = "can_add"
            case date, comments
            case videoDescription = "description"
            case duration, image, id
            case ownerID = "owner_id"
            case title
            case isFavorite = "is_favorite"
            case trackCode = "track_code"
            case type, views
            case localViews = "local_views"
            case platform
            case firstFrame = "first_frame"
            case width, height
            case userID = "user_id"
        }
    }
    
    // MARK: - PostSource
    struct JsonPostSource: Codable {
        let type: JsonPostSourceType
        let platform: JsonPlatform?
    }
    
    enum JsonPlatform: String, Codable {
        case android = "android"
        case iphone = "iphone"
    }
    
    enum JsonPostSourceType: String, Codable {
        case api = "api"
        case mvk = "mvk"
        case vk = "vk"
    }
    
    // MARK: - Donut
    struct JsonDonut: Codable {
        let isDonut: Bool
        
        enum CodingKeys: String, CodingKey {
            case isDonut = "is_donut"
        }
    }
    
    // MARK: - Likes
    struct JsonLikes: Codable {
        let canLike, count, userLikes, canPublish: Int
        
        enum CodingKeys: String, CodingKey {
            case canLike = "can_like"
            case count
            case userLikes = "user_likes"
            case canPublish = "can_publish"
        }
    }
    
    // MARK: - Reposts
    struct JsonReposts: Codable {
        let count, userReposted: Int
        
        enum CodingKeys: String, CodingKey {
            case count
            case userReposted = "user_reposted"
        }
    }
    
    // MARK: - Views
    struct JsonViews: Codable {
        let count: Int
    }
    
}


