//
//  Comment.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/1/21.
//

import FirebaseFirestoreSwift
import Firebase

struct Comment: Identifiable, Codable, Hashable {
    @DocumentID var id: String? // 请注意，我将属性名从 commentId 改为了 id，以符合 Identifiable 的要求
    let postOwnerUid: String
    let commentText: String
    let postId: String
    let timestamp: Timestamp
    let commentOwnerUid: String
    let colorType: CommentColorType
    var user: User?
    var likedBy: [String] = [] // 用户ID的列表，表示哪些用户给这条评论点赞了
    var likesCount: String { // A read-only property, returns the number of likes or "10k+" if likes exceed 10,000
        if likedBy.count > 10000 {
            return "10k+"
        } else {
            return "\(likedBy.count)"
        }
    }

    enum CommentColorType: String, Codable {
        case red
        case blue
    }
}
