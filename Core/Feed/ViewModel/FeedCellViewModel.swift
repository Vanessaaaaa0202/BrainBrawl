//
//  FeedCellViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/31/20.
//

import SwiftUI
import Firebase

@MainActor
class FeedCellViewModel: ObservableObject {
    @Published var post: Post
    @Published var numberOfRedComments: Int = 0
    @Published var numberOfBlueComments: Int = 0
    @Published var showToast = false
    @Published var toastMessage = ""
    @Published var isProcessingLike = false
    @Published var isLoadingBar = true
    @Published var hascommentedfeed : Bool = false



    
    //var showToast: ((String) -> Void)?
    
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
        
        Task {
            try await checkIfUserLikedPost()
            await fetchCommentColorsCount()
            await checkcommentedfeed()
        }
    }
    
    
    func like() async throws{
        guard !isProcessingLike else {return}
        isProcessingLike = true
        do {
            let postExists = try await checkPostExists(post.id ?? "")
            if postExists {
                // Like logic
                print("like")
                self.post.didLike = true
                Task {
                    try await PostService.likePost(post)
                    self.post.likes += 1
                }
            } else {
                DispatchQueue.main.async {
                    self.toastMessage = "Post has been deleted"
                    self.showToast = true
                    // Hide toast after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.showToast = false
                    }
                }
            }
        } catch {
            print("Error in liking the post: \(error)")
        }
        isProcessingLike = false
      }

    
    func unlike() async throws {
        self.post.didLike = false
        print("unlike")
        Task {
            try await PostService.unlikePost(post)
            if self.post.likes > 0 {
                self.post.likes -= 1
            }
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
    
    
    func checkPostExists(_ id: String) async throws -> Bool {
        do {
            _ = try await PostService.fetchPost(withId: id)
    
            return true
        } catch {
            print("Error fetching post: \(error)")
            return false
        }
    }
    
    func checkcommentedfeed() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("当前用户未登录")
            return
        }

        // 继续执行检查用户是否已评论的逻辑
        if let postid = post.id{
            let query = FirestoreConstants
                .PostsCollection
                .document(postid)
                .collection("post-comments")
                .whereField("commentOwnerUid", isEqualTo: uid)
            
            do {
                let snapshot = try await query.getDocuments()
                for document in snapshot.documents {
                    let commentId = document.documentID
                    let commentOwnerUid = document.get("commentOwnerUid") as? String ?? "未知"
                }
                
                self.hascommentedfeed = snapshot.documents.contains(where: {
                    ($0.get("commentOwnerUid") as? String) == uid
                })
            } catch {
                print("检查用户是否已评论出错: \(error)")
            }
        }
    }
}
