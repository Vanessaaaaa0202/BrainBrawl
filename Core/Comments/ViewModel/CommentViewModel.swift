//
//  CommentViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/1/21.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class CommentViewModel: ObservableObject {
    @Published var hasUserChosenColor: Bool = false
    @Published var chosenColorType: Comment.CommentColorType? = nil
    @Published var post: Post
    @Published var numberOfRedComments: Int = 0
    @Published var numberOfBlueComments: Int = 0
    @Published var comments = [Comment]()
    @Published var replies: [Reply] = []
    //小雷：check用户是否在该帖子下发表过评论
    @Published var hasCommented: Bool = false
    var commentColor: Color = .blue
    let postId: String
    private var lastCommentsCount: Int = 0
    //分页加载逻辑
    private var currentPage = 0
    private let pageSize = 10
    private var lastDocument: DocumentSnapshot?
    private var isLoading = false
    @Published var isLastPage = false
    @Published var isLoadingBar = true
    
    
    var totalComments: Int {
        return numberOfRedComments + numberOfBlueComments
    }
    
    var formattedTotalComments: String {
        return totalComments > 10000 ? "10k+" : "\(totalComments)"
    }
    
    var likeString: String {
        let count = post.likes
        let label = count == 1 ? "like" : "likes"

        if count > 10000 {
            return "10k+"
        } else {
            return "\(count)"
        }
    }
    
    init(post: Post) {
        self.post = post
        self.postId = post.id ?? ""
        
        Task {
            try await checkIfUserLikedPost()
            await fetchCommentColorsCount()
            try await fetchComments()
        }
    }
    
    func like() async throws {
        self.post.didLike = true
        Task {
            try await PostService.likePost(post)
            self.post.likes += 1
        }
    }
    
    func unlike() async throws {
        self.post.didLike = false
        Task {
            try await PostService.unlikePost(post)
            self.post.likes -= 1
        }
    }
    
    //小雷：用于将特定评论cell置顶
    func moveToTop(commentId: String) {
        if let index = comments.firstIndex(where: { $0.id == commentId }) {
            let comment = comments[index]
            comments.remove(at: index)
            comments.insert(comment, at: 0)
        }
    }
    //小雷：用于将指定reply在该commentcell内置顶
    func moveReplyToTop(replyId: String) {
        print("moveReplyToTop called with replyId: \(replyId)")
        if let index = replies.firstIndex(where: { $0.replyId == replyId }) {
            let reply = replies[index]
            replies.remove(at: index)
            replies.insert(reply, at: 0)
        }
    }
    
    //小雷：用于检查用户是否评论过该帖子
    func checkIfUserHasCommented() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("当前用户未登录")
            return
        }

        // 继续执行检查用户是否已评论的逻辑
        let query = FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .whereField("commentOwnerUid", isEqualTo: uid)

        do {
            let snapshot = try await query.getDocuments()
            for document in snapshot.documents {
                let commentId = document.documentID
                let commentOwnerUid = document.get("commentOwnerUid") as? String ?? "未知"
            }

            self.hasCommented = snapshot.documents.contains(where: {
                ($0.get("commentOwnerUid") as? String) == uid
            })
        } catch {
            print("检查用户是否已评论出错: \(error)")
        }
    }

    func checkIfUserLikedPost() async throws {
        self.post.didLike = try await PostService.checkIfUserLikedPost(post)
    }
    
    func fetchCommentColorsCount() async {
        let redQuery = Firestore.firestore()
            .collection("posts")
            .document(post.id ?? "")
            .collection("post-comments")
            .whereField("colorType", isEqualTo: "red")
        
        let blueQuery = Firestore.firestore()
            .collection("posts")
            .document(post.id ?? "")
            .collection("post-comments")
            .whereField("colorType", isEqualTo: "blue")
        
        guard let redSnapshot = try? await redQuery.getDocuments() else { return }
        guard let blueSnapshot = try? await blueQuery.getDocuments() else { return }
        
        numberOfRedComments = redSnapshot.documents.count
        numberOfBlueComments = blueSnapshot.documents.count
        DispatchQueue.main.async {
            self.isLoadingBar = false
        }
    }
    
    func uploadComment(commentText: String, commentColor: Comment.CommentColorType) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let comment = Comment(
            postOwnerUid: post.ownerUid,
            commentText: commentText,
            postId: postId,
            timestamp: Timestamp(),
            commentOwnerUid: uid,
            colorType: commentColor // 设置评论的颜色
        )
        self.hasUserChosenColor = true
        self.chosenColorType = comment.colorType
        
        guard let commentData = try? Firestore.Encoder().encode(comment) else { return }
        
        let _ = try await FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .addDocument(data: commentData)
        self.comments.insert(comment, at: 0)
        
        print("Comment Text from CommentViewModel:", commentText)
        
        NotificationService.uploadNotification(toUid: self.post.ownerUid, type: .comment, post: self.post, comment: comment)

    }
    
    
    
    @MainActor
    func fetchComments() async throws {
        let query = FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .order(by: "timestamp", descending: true)
        
        do {
            let snapshot = try await query.getDocuments()
            
            var tempComments = snapshot.documents.compactMap({ try? $0.data(as: Comment.self) })
            
            for i in 0 ..< tempComments.count {
                let comment = tempComments[i]
                guard let commentId = comment.id else {
                    print("Comment ID is nil for comment at index \(i)")
                    continue
                }
                if let user = try? await UserService.fetchUser(withUid: comment.commentOwnerUid) {
                    tempComments[i].user = user
                } else {
                    print("Failed to fetch user for comment \(commentId)")
                }
            }

            // 筛选逻辑
            if let chosenColorType = chosenColorType {
                self.comments = tempComments.filter { $0.colorType == chosenColorType }
            } else {
                self.comments = tempComments // 如果 chosenColorType 为 nil，则显示所有评论
            }
        } catch {
            print("Error fetching comments: \(error)")
        }
    }
    
    func fetchPageComments() async throws {
        guard !isLoading && !isLastPage else { return }
        isLoading = true

        var query = FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .order(by: "timestamp", descending: true)
            .limit(to: pageSize)

        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        do {
            let snapshot = try await query.getDocuments()
                    let documents = snapshot.documents
                    guard !documents.isEmpty else {
                        isLastPage = true
                        isLoading = false
                        return
                    }

            var fetchedComments = [Comment]()
            for document in documents {
                let comment = try document.data(as: Comment.self)
                fetchedComments.append(comment)
            }

            // 异步地获取每个评论的用户信息
            for i in 0 ..< fetchedComments.count {
                let user = try await UserService.fetchUser(withUid: fetchedComments[i].commentOwnerUid)
                fetchedComments[i].user = user
            }

            DispatchQueue.main.async {
                if let chosenColorType = self.chosenColorType {
                    // 筛选指定颜色类型的评论
                    self.comments += fetchedComments.filter { $0.colorType == chosenColorType }
                } else {
                    // 如果 chosenColorType 为 nil，则显示所有评论
                    self.comments += fetchedComments
                }

                self.lastDocument = documents.last
                self.isLoading = false
            }

            self.currentPage += 1
        } catch {
            print("Error fetching comments: \(error)")
            self.isLoading = false
        }
    }
}

// MARK: - Deletion

extension CommentViewModel {

        
    func checkPostComments(_ id: String) async throws -> Bool {
        do {
            _ = try await PostService.fetchPost(withId: id)
            return true
        } catch {
            print("Error fetching post: \(error)")
            return false
        }
    }
    
    
    func toggleLike(for commentId: String) async {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }

        // 获取相关的comment index
        if let index = comments.firstIndex(where: { $0.id == commentId }) {
            var comment = comments[index]
            
            if comment.likedBy.contains(currentUserUid) {
                // Unlike
                if let position = comment.likedBy.firstIndex(of: currentUserUid) {
                    comment.likedBy.remove(at: position)
                }
            } else {
                // Like
                comment.likedBy.append(currentUserUid)
                // Notification Comment like
                NotificationService.uploadNotification(toUid: comment.commentOwnerUid, type: .likeComment, post: self.post, comment: comment)
                
            }

            comments[index] = comment
            
            // 保存更改到Firebase数据库中
            do {
                try await FirestoreConstants.PostsCollection
                    .document(postId)
                    .collection("post-comments")
                    .document(commentId)
                    .setData(["likedBy": comment.likedBy], merge: true)
                   
                    
                    
            } catch {
                print("Failed to update the like status in Firestore: \(error.localizedDescription)")
            }
        }
    }

    
    func likeComment(comment: Comment) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if comment.likedBy.contains(uid) {
            // 如果已经点赞，则取消点赞
            try await unlikeComment(comment: comment)
        } else {
            // 否则，添加点赞
            var updatedComment = comment
            updatedComment.likedBy.append(uid)
            try await updateCommentInFirebase(updatedComment)
        }
    }
    
    func unlikeComment(comment: Comment) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        var updatedComment = comment
        updatedComment.likedBy.removeAll { $0 == uid }
        try await updateCommentInFirebase(updatedComment)
    }
    
    private func updateCommentInFirebase(_ comment: Comment) async throws {
        guard let commentId = comment.id else { return }
        
        let data = try Firestore.Encoder().encode(comment)
        try await FirestoreConstants
            .PostsCollection
            .document(postId)
            .collection("post-comments")
            .document(commentId)
            .setData(data, merge: true)
    }

    func deleteAllComments() {
        FirestoreConstants.PostsCollection.getDocuments { snapshot, _ in
            guard let postIDs = snapshot?.documents.compactMap({ $0.documentID }) else { return }
            
            for id in postIDs {
                FirestoreConstants.PostsCollection.document(id).collection("post-comments").getDocuments { snapshot, _ in
                    guard let commentIDs = snapshot?.documents.compactMap({ $0.documentID }) else { return }
                    
                    for commentId in commentIDs {
                        FirestoreConstants.PostsCollection.document(id).collection("post-comments").document(commentId).delete()
                    }
                }
            }
        }
    }
}
