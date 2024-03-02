//
//  Reply.swift
//  InstagramSwiftUITutorial
//
//  Created by Vanessa on 2023/11/11.
//

import FirebaseFirestoreSwift
import Firebase

struct Reply: Identifiable, Codable, Hashable {
    
    @DocumentID var replyId: String?
    let postOwnerUid: String  // 所属帖子的所有者ID
    let replyText: String  // 回复文本
    let postId: String  // 所属帖子的ID
    let commentId: String  // 所属评论的ID
    let timestamp: Timestamp  // 发布时间
    let commentOwnerUid: String
    let replyOwnerUid: String  // 回复者的用户ID
    let parentReplyId: String?
    var user: User?  // 关联的用户模型（可选）
    // 用户ID列表，表示哪些用户给这条回复点赞了
    var likedBy: [String] = []
    // 只读属性，返回点赞的数量
    var likesCount: String { // A read-only property, now returns a String
        if likedBy.count > 10000 {
            return "10k+"
        } else {
            return "\(likedBy.count)"
        }
    }
    var id: String {
        return replyId ?? NSUUID().uuidString
    }
}
