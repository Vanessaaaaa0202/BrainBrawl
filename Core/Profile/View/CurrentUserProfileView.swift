//
//  TabProfileView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 5/3/23.
//
//  TabProfileView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 5/3/23.
//

import SwiftUI

struct CurrentUserProfileView: View {
    let user: User
    @EnvironmentObject var viewModel: ProfileViewModel
    @State private var selectedView: SelectedView = .post // 新状态变量
    @StateObject var replyGridViewModel = ReplyGridViewModel()  // 创建 ReplyGridViewModel 实例
    @State private var showSettingsSheet = false
    @State private var selectedSettingsOption: SettingsItemModel?
    @State private var showDetail = false
    @StateObject var postGridViewModel: PostGridViewModel  // 新增
    
    enum SelectedView {
        case post
        case reply
    }

    
    init(user: User, postGridViewModel: PostGridViewModel) {
        self.user = user
        self._postGridViewModel = StateObject(wrappedValue: postGridViewModel)
        //self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
        
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    ProfileHeaderView(viewModel: viewModel)
                    // 添加按钮
                    HStack {
                        Button(action: {
                            selectedView = .post
                        }) {
                            Text("Topics")
                                .padding()
                                .foregroundColor(selectedView == .post ? .blue : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button(action: {
                            selectedView = .reply
                            Task {
                                try? await replyGridViewModel.fetchUserComments(userId: user.id)
                            }
                        }) {
                            Text("Replies")
                                .padding()
                                .foregroundColor(selectedView == .reply ? .blue : .gray)

                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // 根据选中的视图显示不同的内容
                    if selectedView == .post {
                        PostGridView(config: .profile(user), viewModel: postGridViewModel, profileViewModel: viewModel)
                    } else if selectedView == .reply {
                        ReplyGridView(viewModel: replyGridViewModel, profileViewModel: viewModel)
                    }
                }
            }
            .onAppear {
                selectedView = .post // 确保显示的是 "Topics"
                postGridViewModel.fetchPosts(forConfig: .profile(user))
                // 如果需要，可以在这里添加逻辑来刷新 "Topics" 数据
            }//MARK: 只保留username
            .navigationTitle(viewModel.user.username)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Post.self) { selectedPost in
                CommentsView(post: selectedPost, targetCommentId: nil, targetReplyId: nil)
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user)
            }
            .navigationDestination(isPresented: $showDetail, destination: {
                Text(selectedSettingsOption?.title ?? "")
            })
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView(selectedOption: $selectedSettingsOption)
                    .presentationDetents([.height(CGFloat(SettingsItemModel.allCases.count * 56))])
                    .presentationDragIndicator(.visible)
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        selectedSettingsOption = nil
                        showSettingsSheet.toggle()
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .onChange(of: selectedSettingsOption) { newValue in
                guard let option = newValue else { return }
                
                if option != .logout {
                    self.showDetail.toggle()
                } else {
                    AuthService.shared.signout()
                }
            }
        }
    }
}

/*
struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileView(user: dev.user)
    }
}*/
