//
//  PostGridView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//
import SwiftUI
import Kingfisher

struct PostGridView: View {
    let config: PostGridConfiguration
    @StateObject var viewModel: PostGridViewModel
    var profileViewModel: ProfileViewModel  // 新增 profileViewModel
    
    init(config: PostGridConfiguration, viewModel: PostGridViewModel, profileViewModel: ProfileViewModel) {
        self.config = config
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.profileViewModel = profileViewModel // 添加这行代码
    }
    
    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                Text("Loading")
                    .foregroundColor(.gray)
                    .padding(.top, 90)
                ProgressView()
                    .scaleEffect(1, anchor: .center)
                    .padding(.top)
            } else {
                if viewModel.posts.isEmpty {
                    // 当没有帖子时显示的消息
                    Text("No Posts")
                        .padding(.top, 100)
                        .font(.title)
                        .foregroundColor(.gray)
                } else {
                    LazyVStack(spacing: 18) {
                        ForEach(viewModel.posts) { post in
                            PostGridCell(post: post, profileViewModel: profileViewModel, showColorCommentsButtons: false, onDelete: {
                                viewModel.removePost(withId: post.id ?? "")
                            })
                            //.border(Color.red)
                            .onAppear {
                                guard let index = viewModel.posts.firstIndex(where: { $0.id == post.id }) else { return }
                                if case .explore = config, index == viewModel.posts.count - 1 {
                                    viewModel.fetchExplorePagePosts()
                                }
                            }
                        }
                    }
                }
            }
            Text("—— The End ——")
                .foregroundColor(.gray)
                .font(.system(size: 14))
                .padding(.top, 10)
                .padding(.bottom,7)
        }
    }
}



/*
struct PostGridView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(dev.users, id: \.id) { user in
            PostGridView(config: .profile(user))
        }
        
    }
}*/
