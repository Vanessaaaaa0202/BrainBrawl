import Foundation
import Firebase
import FirebaseFirestoreSwift

class ReplyGridViewModel: ObservableObject {
    @Published var userComments = [Comment]()  // 存储用户评论
    @Published var mainComments = [Comment]()  // 存储主评论
    @Published var postTitles = [String: String]() // 存储 postId 和对应的 post title
    @Published var posts = [String: Post]()
    @Published var commentReplies = [String: [Comment]]() // 存储评论的回复，键为评论的 ID
    @Published var isLoading = false  // Track loading state
    
    
    
    func fetchPostById(postId: String) async throws -> Post? {
        let postDocSnapshot = try await FirestoreConstants.PostsCollection.document(postId).getDocument()
        let post = try postDocSnapshot.data(as: Post.self)
        return post
    }
    
    @MainActor
    func fetchUserComments(userId: String) async throws {
        self.isLoading = true  // Start loading
        let postsSnapshot = try await FirestoreConstants.PostsCollection.getDocuments()
        var tempComments = [Comment]()
        
        for document in postsSnapshot.documents {
            let postId = document.documentID
            let postTitle = document.data()["title"] as? String ?? "No Title"
            self.postTitles[postId] = postTitle
            
            if let post = try await fetchPostById(postId: postId) {
                self.posts[postId] = post
            }

            let commentsSnapshot = try await FirestoreConstants.PostsCollection
                .document(postId)
                .collection("post-comments")
                .whereField("commentOwnerUid", isEqualTo: userId)
                .order(by: "timestamp", descending: true)
                .getDocuments()

            for commentDocument in commentsSnapshot.documents {
                if var comment = try? commentDocument.data(as: Comment.self) {
                        // 尝试获取每个评论的用户信息
                        let userDocSnapshot = try await Firestore.firestore().collection("users").document(comment.commentOwnerUid).getDocument()
                        // 尝试将用户数据解码为 User 实例
                        comment.user = try? userDocSnapshot.data(as: User.self)
                        tempComments.append(comment)
                    }
            }
        }

        self.mainComments = tempComments.sorted { $0.timestamp.compare($1.timestamp) == .orderedDescending }
        self.isLoading = false  // End loading
    }

}


extension ReplyGridViewModel {
    func toggleLike(for commentId: String) async {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }

        if let index = mainComments.firstIndex(where: { $0.id == commentId }) {
            var comment = mainComments[index]
            // Check if the post associated with the comment is available
                guard let post = posts[comment.postId] else {
                    print("Post not found for the comment")
                return
            }

            if comment.likedBy.contains(currentUserUid) {
                // Unlike
                comment.likedBy.removeAll { $0 == currentUserUid }
            } else {
                // Like
                comment.likedBy.append(currentUserUid)
                //Add notification logic here
                NotificationService.uploadNotification(toUid: comment.commentOwnerUid, type: .likeComment, post: post, comment: comment)
            }

            DispatchQueue.main.async {
                       self.mainComments[index] = comment
                }

            // Update in Firestore
            do {
                try await FirestoreConstants.PostsCollection
                    .document(comment.postId)  // Use the correct document path
                    .collection("post-comments")
                    .document(commentId)
                    .setData(["likedBy": comment.likedBy], merge: true)
            } catch {
                print("Error updating likes in Firestore: \(error.localizedDescription)")
            }
        }
    }
}
