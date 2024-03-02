import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class MainCommentViewModel: ObservableObject {
    var commentColorType: Comment.CommentColorType
    var commentColor: Color
    private let post: Post
    private let postId: String
    @Published var mainComments = [Comment]()
    
    // 指定的初始化方法
    init(post: Post, commentColorType: Comment.CommentColorType) {
         self.post = post
         self.postId = post.id ?? ""
         self.commentColorType = commentColorType
         self.commentColor = commentColorType.color
         Task { try await fetchMainComments() }
     }

    func uploadMainComment(commentText: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 首先生成一个新的文档ID
        let documentRef = FirestoreConstants.PostsCollection.document(postId).collection("post-comments").document()

        // 现在在创建Comment对象时，可以直接使用这个新生成的ID
        let mainComment = Comment(
            id: documentRef.documentID, // 使用生成的文档ID
            postOwnerUid: post.ownerUid,
            commentText: commentText,
            postId: postId,
            timestamp: Timestamp(),
            commentOwnerUid: uid,
            colorType: self.commentColorType
        )

        do {
            let mainCommentData = try Firestore.Encoder().encode(mainComment)
            // 使用先前生成的documentRef来添加文档，这样就能保证ID与Comment对象中的一致
            try await documentRef.setData(mainCommentData)

            self.mainComments.insert(mainComment, at: 0)

            NotificationService.uploadNotification(toUid: self.post.ownerUid, type: .comment, post: self.post, comment: mainComment)
        } catch {
            throw error // 如果出现错误，抛出以便调用者处理
        }
    }


    
    func fetchMainComments() async throws {
        let query = FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .order(by: "timestamp", descending: true)
        
        guard let snapshot = try? await query.getDocuments() else { return }
        self.mainComments = snapshot.documents.compactMap({ try? $0.data(as: Comment.self) })
        
        for i in 0 ..< mainComments.count {
            let comment = mainComments[i]
            let user = try await UserService.fetchUser(withUid: comment.commentOwnerUid)
            mainComments[i].user = user
        }
    }
}

enum CommentType: String, Codable {
    case red
    case blue
}

extension Comment.CommentColorType {
    var color: Color {
        switch self {
        case .red:
            return Color(red: 249/255.0, green: 97/255.0, blue: 103/255.0, opacity: 1)
        case .blue:
            return Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1)
        }
    }
}
