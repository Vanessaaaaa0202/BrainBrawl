import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class ReplyViewModel: ObservableObject {
    private let postId: String
    private let commentId: String
    private let commentOwnerUid: String  // 新增
    @Published var replies = [Reply]()

    init(postId: String, commentId: String, commentOwnerUid: String) {
            self.postId = postId
            self.commentId = commentId
            self.commentOwnerUid = commentOwnerUid  // 设置属性
            Task {
                await fetchReplies()
            }
        }
    
    //小雷： fetch用户评论颜色的方法
    func getColorForUserInPost(userId: String, postId: String) async -> Comment.CommentColorType? {
        // 这里的实现将取决于您如何存储这些信息
        // 以下是一个假设的实现，您需要根据实际情况进行调整

        let query = Firestore.firestore()
            .collection("posts")
            .document(postId)
            .collection("post-comments")
            .whereField("commentOwnerUid", isEqualTo: userId)
            .limit(to: 1)  // 假设我们只关心最近的一条评论

        do {
            let snapshot = try await query.getDocuments()
            if let document = snapshot.documents.first,
               let colorType = document.get("colorType") as? String {
                return Comment.CommentColorType(rawValue: colorType)
            }
        } catch {
            print("Error fetching comment color: \(error)")
        }

        return nil
    }
    
    func uploadReply(replyText: String, parentReplyId: String? = nil) async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let newReply = Reply(
            postOwnerUid: "", // 更新为实际的帖子所有者 UID
            replyText: replyText,
            postId: self.postId,
            commentId: self.commentId,
            timestamp: Timestamp(),
            commentOwnerUid: commentOwnerUid,
            replyOwnerUid: uid,
            parentReplyId: parentReplyId
        )
        
        // 尝试上传新回复
        do {
            let replyData = try Firestore.Encoder().encode(newReply)
            let _ = try await FirestoreConstants
                .PostsCollection
                .document(self.postId)
                .collection("post-comments")
                .document(self.commentId)
                .collection("comment-replies")
                .addDocument(data: replyData)
            
            self.replies.insert(newReply, at: 0)
            await fetchReplies()
        } catch {
            print("Error uploading reply: \(error)")
            return
        }
        
        // 如果存在父回复ID，则获取父回复
        if let parentReplyId = parentReplyId {
            do {
                let parentReplySnapshot = try await FirestoreConstants
                    .PostsCollection
                    .document(self.postId)
                    .collection("post-comments")
                    .document(self.commentId)
                    .collection("comment-replies")
                    .document(parentReplyId)
                    .getDocument()
                
                if let parentReply = try? parentReplySnapshot.data(as: Reply.self) {
                    // 向父回复的所有者发送通知
                    NotificationService.uploadNotificationForReply(toUid: parentReply.replyOwnerUid, type: .replyToReply, reply: newReply)
                }
            } catch {
                print("Error fetching parent reply: \(error)")
            }
        }else{
            NotificationService.uploadNotificationForReply(toUid: self.commentOwnerUid, type: .replyToComment, reply: newReply)
        }
    }

    @MainActor
    func fetchReplies() async {

        let query = FirestoreConstants
            .PostsCollection
            .document(self.postId)
            .collection("post-comments")
            .document(self.commentId)
            .collection("comment-replies")
            .order(by: "timestamp", descending: true)
        
        do {
            let snapshot = try await query.getDocuments()
            var updatedReplies = [Reply]()

            for document in snapshot.documents {
                var reply = try? document.data(as: Reply.self)

                // 获取回复者的用户信息
                if let replyOwnerUid = reply?.replyOwnerUid {
                    if let user = try? await UserService.fetchUser(withUid: replyOwnerUid) {
                        reply?.user = user // 将用户信息赋值给回复
                    } else {
                        print("Failed to fetch user for reply \(document.documentID)")
                    }
                }

                if let reply = reply {
                    updatedReplies.append(reply)
                }
            }

            DispatchQueue.main.async {
                self.replies = updatedReplies
            }
        } catch {
            print("Error fetching replies: \(error)")
            
        }
        
    }


    
    func toggleLike(for replyId: String) async {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        
        guard let index = replies.firstIndex(where: { $0.replyId == replyId }) else { return }
        var reply = replies[index]
        
        let wasLiked = reply.likedBy.contains(currentUserUid)
        if wasLiked {
            // 如果已经点赞，则取消点赞
            reply.likedBy.removeAll { $0 == currentUserUid }
        } else {
            // 如果未点赞，则添加点赞
            reply.likedBy.append(currentUserUid)

            // 用户刚刚点赞，发送通知
            NotificationService.uploadNotificationForReply(toUid: reply.replyOwnerUid, type: .likeReply, reply: reply)
        }
        
        // 更新回复点赞状态
        do {
            let data = try Firestore.Encoder().encode(reply)
            try await FirestoreConstants.PostsCollection
                .document(self.postId)
                .collection("post-comments")
                .document(self.commentId)
                .collection("comment-replies")
                .document(replyId)
                .setData(data, merge: true)
            
            DispatchQueue.main.async {
                self.replies[index] = reply
            }
        } catch {
            print("Failed to update like status: \(error)")
        }
    }
}

