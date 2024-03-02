//
//  PostGridViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/31/20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

enum PostGridConfiguration {
    case explore
    case profile(User)
}

class PostGridViewModel: ObservableObject {
    @Published var user: User?
    @Published var posts = [Post]()
    @Published var isLoading = false  // Track loading state
    private let config: PostGridConfiguration
    private var lastDoc: QueryDocumentSnapshot?
//    private var userListeners = [String: ListenerRegistration]()
//    private var db = Firestore.firestore()
    
    
    init(config: PostGridConfiguration) {
        self.config = config
        if case .profile(let user) = config {
            self.user = user
        }
        fetchPosts(forConfig: config)
    }
    
    func fetchPosts(forConfig config: PostGridConfiguration) {
        switch config {
        case .explore:
            fetchExplorePagePosts()
        case .profile(let user):
            Task { try await fetchUserPosts(forUser: user) }
        }
        //print("成功")
    }
    
    func removePost(withId id: String) {
        DispatchQueue.main.async {
            self.posts.removeAll { $0.id == id }
        }
    }
    
    
    func fetchExplorePagePosts() {
        let query = FirestoreConstants.PostsCollection.limit(to: 20).order(by: "timestamp", descending: true)
        
        if let last = lastDoc {
            let next = query.start(afterDocument: last)
            next.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents, !documents.isEmpty else { return }
                self.lastDoc = snapshot?.documents.last
                self.posts.append(contentsOf: documents.compactMap({ try? $0.data(as: Post.self) }))
            }
        } else {
            query.getDocuments { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self.posts = documents.compactMap({ try? $0.data(as: Post.self) })
                self.lastDoc = snapshot?.documents.last
            }
        }
    }    
    
//    private func listenToUserUpdates(forOwnerUid ownerUid: String) {
//        // 监听用户文档的变化
//        let listener = db.collection("users").document(ownerUid).addSnapshotListener { [weak self] documentSnapshot, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("监听用户更新时出错: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let snapshot = documentSnapshot, snapshot.exists,
//                  let updatedUser = try? snapshot.data(as: User.self) else { return }
//
//            DispatchQueue.main.async {
//                self.posts = self.posts.map { post in
//                    var updatedPost = post
//                    if updatedPost.ownerUid == updatedUser.id {
//                        updatedPost.user = updatedUser
//                    }
//                    return updatedPost
//                }
//            }
//        }
//        
//        // 保存监听器引用，以便可以在不需要时移除监听器
//        userListeners[ownerUid] = listener
//    }
//
//    func addUserListeners() {
//        // 为所有当前加载的帖子的用户添加更新监听器
//        for post in posts {
//            listenToUserUpdates(forOwnerUid: post.ownerUid)
//        }
//    }
    
    @MainActor
    func fetchUserPosts(forUser user: User) async throws {
        self.isLoading = true
        let unsortedPosts = try await PostService.fetchUserPosts(user: user)
        self.posts = unsortedPosts.sorted(by: { $0.timestamp.compare($1.timestamp) == .orderedDescending })
        self.isLoading = false  // Start loading
    }
}
