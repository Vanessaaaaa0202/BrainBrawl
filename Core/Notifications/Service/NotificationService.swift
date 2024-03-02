//
//  NotificationService.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/20/23.
//

import Firebase

struct NotificationService {
    
    static func fetchNotifications() async -> [Notification] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        let query = FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)

        guard let snapshot = try? await query.getDocuments() else { return [] }
        return snapshot.documents.compactMap({ try? $0.data(as: Notification.self) })
    }
    
    static func uploadNotification(toUid uid: String, type: NotificationType, post: Post? = nil, comment: Comment? = nil, reply: Reply? = nil) {
        
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard uid != currentUid else {return}
        
        if let commentID = comment?.id {
            print("This is a commentID: \(commentID)")
        } else {
            print("CommentID is nil")
        }
        
        let notification = Notification(
            postId: post?.id ?? comment?.postId, // 如果post为nil，则使用评论的postId
            commentId: comment?.id, // 使用评论的id
            replyId: reply?.id,
            timestamp: Timestamp(),
            type: type,
            uid: currentUid,
            targetCommentId: comment?.id,
            targetReplyId: reply?.id,
            viewed: false,
            text: comment?.commentText ?? reply?.replyText // 使用构造的通知文本
        )
        
        do {
            print("Eric testing comment")
            let data = try Firestore.Encoder().encode(notification)
            FirestoreConstants
                .NotificationsCollection
                .document(uid)
                .collection("user-notifications")
                .addDocument(data: data)
        } catch {
            print("Error encoding notification: \(error)")
        }
    }

    
    static func uploadNotificationForReply(toUid uid: String, type: NotificationType, reply: Reply) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }

        let notification = Notification(
            postId: reply.postId,
            replyId: reply.id,
            timestamp: Timestamp(),
            type: type,
            uid: currentUid,
            targetCommentId: reply.commentId,
            text: reply.replyText // 设置回复的文本内容
        )
        guard let data = try? Firestore.Encoder().encode(notification) else { return }

        FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .addDocument(data: data)
    }

    
    static func deleteNotification(toUid uid: String, type: NotificationType, postId: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let snapshot = try await FirestoreConstants
            .NotificationsCollection
            .document(uid)
            .collection("user-notifications")
            .whereField("uid", isEqualTo: currentUid)
            .getDocuments()
        
        for document in snapshot.documents {
            let notification = try? document.data(as: Notification.self)
            guard notification?.type == type else { return }
            
            if postId != nil {
                guard postId == notification?.postId else { return }
            }
            
            try await document.reference.delete()
        }
    }
}
