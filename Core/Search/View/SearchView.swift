//
//  SearchView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @StateObject var feedViewModel = FeedViewModel() // Used for post search

    var body: some View {
        NavigationStack {
            VStack {
                if searchText.isEmpty {
                        Spacer()
                        Text("Find interesting brawl topics!").foregroundStyle(Color(.systemGray3)).font(.system(size: 19))
                        Spacer()
                } else {
                    SearchResultsView(viewModel: feedViewModel)
                }
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user)
            }
            .navigationDestination(for: Post.self) { selectedPost in
                CommentsView(post: selectedPost, targetCommentId: nil, targetReplyId: nil)
            }
            .navigationDestination(for: SearchViewModelConfig.self) { config in
                UserListView(config: config)
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always)) // 搜索框永久显示
            .onChange(of: searchText) { newValue in
                if newValue.isEmpty {
                    // 当搜索文本为空时，清空搜索结果
                    feedViewModel.filteredPosts = []
                } else {
                    // 否则根据新值过滤动态
                    feedViewModel.searchPosts(withText: newValue)
                }
            }
        }
    }
}
