//
//  ProfileView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//

import SwiftUI

struct ProfileView: View {
    let user: User
    @StateObject var viewModel: ProfileViewModel
    @StateObject var replyGridViewModel = ReplyGridViewModel()  // 创建 ReplyGridViewModel 实例
    @State private var selectedView: SelectedView = .post  // 新状态变量
    @State private var isSticky_tr: Bool = false //检测topics和replies是是否固定
    @StateObject var postGridViewModel: PostGridViewModel
    
    enum SelectedView {
            case post
            case reply
        }
    
    init(user: User) {
        self.user = user
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
        self._postGridViewModel = StateObject(wrappedValue: PostGridViewModel(config: .profile(user)))  // 新增
    }
    
    var body: some View {
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
                        PostGridView(config: .profile(user), viewModel: postGridViewModel, profileViewModel: viewModel).environmentObject(viewModel)
                    } else if selectedView == .reply {
                        ReplyGridView(viewModel: replyGridViewModel, profileViewModel: viewModel)
                    }
            }
            .padding(.top)
        }
        //MARK: 只显示username
        .navigationTitle(viewModel.user.username)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                //=================================新增profile里的功能bar需要block别的用户
                Menu {
                    //Block button
                        Button(role: .destructive) {
                            // Do something
                        } label: {
                            Label("Block", systemImage: "eye.slash")
                        }
                    
                    //Cancel
                    Button("Cancel", role: .destructive) {
                        // Do something
                    }
                    
                } label: {
                    Label("", systemImage: "ellipsis").padding(.bottom,6)
                }
            }
        }
    }
}

/*
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(dev.users, id: \.id) { user in
            ProfileView(user: user)
        }
    }
}*/

