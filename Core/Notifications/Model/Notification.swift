//
//  Notification.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/2/21.
//

import FirebaseFirestoreSwift
import Firebase

struct Notification: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var postId: String?
    var commentId: String?
    var replyId: String?
    let timestamp: Timestamp
    let type: NotificationType
    let uid: String
    var targetCommentId: String?
    var targetReplyId: String?
    var isFollowed: Bool? = false
    var post: Post?
    var user: User?
    var reply: Reply?
    
    var viewed: Bool? = false // New property to track if the notification has been viewed
    var text: String? // 新增属性，用于存储评论或回复的具体内容
}
