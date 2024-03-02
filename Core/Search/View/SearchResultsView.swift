//
//  SearchResultsView.swift
//  InstagramSwiftUITutorial
//
//  Created by 蒋凯笛 on 11/13/23.
//

import SwiftUI

struct SearchResultsView: View {
    @ObservedObject var viewModel: FeedViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 18) {
                ForEach(viewModel.filteredPosts) { post in
                    NavigationLink(destination: FeedCell(post: post)) {
                        FeedCell(post: post)
                    }
                    .buttonStyle(PlainButtonStyle()) // 确保整个FeedCell都是可点击的
                }
            }.padding(.top)
        }
    }
}
