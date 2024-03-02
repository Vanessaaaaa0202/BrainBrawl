//
//  FeedViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/31/20.
//

import SwiftUI
import Firebase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var filteredPosts = [Post]() // This will store the search results
    
    private var currentPage = 0
    private let pageSize = 10
    private var lastDocument: DocumentSnapshot?
    private var isLoading = false
    // 将 isLastPage 的访问级别改为 internal 或 public
    @Published var isLastPage = false
    
    init() {
        Task { try await fetchAllPostsWithUserData() }
    }
        
    private func fetchPostIDs() async -> [String] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snapshot = try? await FirestoreConstants.UserCollection.document(uid).collection("user-feed").getDocuments()
        return snapshot?.documents.map({ $0.documentID }) ?? []
    }
    
    func refreshPosts() {
        currentPage = 0
        isLastPage = false
        posts = []
        lastDocument = nil // 重置分页
        Task { try await fetchAllPostsWithUserData() }
    }
    func loadMorePosts() {
        Task { try await fetchAllPostsWithUserData() }
    }
    
    func fetchPosts() async throws {
        let postIDs = await fetchPostIDs()
                
        try await withThrowingTaskGroup(of: Post?.self, body: { group in
            var posts: [Post] = []
            
            for id in postIDs {
                group.addTask {
                    do {
                        let post = try await PostService.fetchPost(withId: id)
                        guard post != nil else {
                            print("DEBUG: Post with ID \(id) does not exist anymore.")
                            return nil
                        }
                        return post
                    } catch {
                        print("DEBUG: Error fetching post with ID \(id) - \(error)")
                        return nil  // Now it's okay to return nil
                    }
                }
            }
            
            for try await post in group {
                if let validPost = post {
                    posts.append(try await fetchPostUserData(post: validPost))
                }
            }
            
            self.posts = posts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
        })

    }
    
    private func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
    
        async let postUser = try await UserService.fetchUser(withUid: post.ownerUid)
        result.user = try await postUser

        return result
    }
}

// fetch all posts
extension FeedViewModel {
    func fetchAllPosts() async throws {
        let snapshot = try? await FirestoreConstants.PostsCollection.order(by: "timestamp", descending: true).getDocuments()
        guard let documents = snapshot?.documents else { return }
        self.posts = documents.compactMap({ try? $0.data(as: Post.self) })
        
        // fetches users in sync
//        for i in 0 ..< posts.count {
//            let post = posts[i]
//            async let user = try await UserService.fetchUser(withUid: post.ownerUid)
//            posts[i].user = try await user
//        }
//
//        self.posts = posts
    }
    
    func fetchAllPostsWithUserData() async throws {
        guard !isLoading && !isLastPage else { return }
                isLoading = true

                var query = FirestoreConstants.PostsCollection.order(by: "timestamp", descending: true).limit(to: pageSize)
                if let lastDocument = lastDocument {
                    query = query.start(afterDocument: lastDocument)
                }

                let snapshot = try? await query.getDocuments()
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    isLastPage = true
                    isLoading = false
                    return
                }

                self.posts += documents.compactMap({ try? $0.data(as: Post.self) })
                currentPage += 1
                isLoading = false

                self.lastDocument = documents.last

        await withThrowingTaskGroup(of: Void.self, body: { group in
            for post in posts {
                group.addTask { try await self.fetchUserData(forPost: post) }
            }
        })
    }
    
    func fetchUserData(forPost post: Post) async throws {
        let user = try await UserService.fetchUser(withUid: post.ownerUid)

        // Update posts array in a safe manner
        DispatchQueue.main.async {
            if let indexOfPost = self.posts.firstIndex(where: { $0.id == post.id }) {
                self.posts[indexOfPost].user = user
            }
        }
    }


}

// async code but still fetches things sync becuase of for loop
extension FeedViewModel {
    func fetchPostsFromFollowedUsers() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var posts = [Post]()
        
        let snapshot = try? await FirestoreConstants
            .UserCollection
            .document(uid)
            .collection("user-feed")
            .getDocuments()
        
        guard let postIDs = snapshot?.documents.map({ $0.documentID }) else { return }
        
        for id in postIDs {
            let postSnapshot = try? await FirestoreConstants.PostsCollection.document(id).getDocument()
            guard let post = try? postSnapshot?.data(as: Post.self) else { return }
            posts.append(post)
        }
        
        self.posts = posts
    }
}

// MARK: - Search Functionality
extension FeedViewModel {
    
    // Call this method to update the filtered posts based on the search text
    func searchPosts(withText searchText: String) {
        // If the search text is empty, don't filter the posts
        guard !searchText.isEmpty else {
            filteredPosts = posts
            return
        }

        // Filter the posts by title or content
        filteredPosts = posts.filter { post in
            post.title.lowercased().contains(searchText.lowercased()) ||
            post.caption.lowercased().contains(searchText.lowercased())
        }
    }
}
