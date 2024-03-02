//
//  ProfileActionButtonView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/27/20.
//

import SwiftUI

struct ProfileActionButtonView: View {
    @ObservedObject var viewModel: ProfileViewModel
    var isFollowed: Bool { viewModel.user.isFollowed ?? false }
    @State var showEditProfile = false
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            if viewModel.user.isCurrentUser {
                // 当前用户，显示编辑资料按钮，样式与其他按钮一致
                Button(action: { showEditProfile.toggle() }) {
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width:  UIScreen.main.bounds.width*0.90, height: 32)
                        .foregroundColor(.blue) // 字体颜色为蓝色
                        .background(Color.white) // 按钮背景为白色
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                .fullScreenCover(isPresented: $showEditProfile) {
                    EditProfileView(user: $viewModel.user)
                }
            } else {
                // 其他用户，显示关注和消息按钮
                HStack(spacing: 12) {
                    // 关注按钮
                    Button(action: { isFollowed ? viewModel.unfollow() : viewModel.follow() }) {
                        Text(isFollowed ? "Following" : "Follow")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: UIScreen.main.bounds.width*0.90, height: 32)
                            .foregroundColor(.blue)
                            .background(Color.white) // 按钮背景保持为白色
                            .cornerRadius(24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                    }
//MARK: 注释掉消息按钮，暂时先不提供
                    // 消息按钮
                   // NavigationLink(destination: ChatView(user: viewModel.user)) {
                   //     Text("Message")
                   //         .font(.system(size: 14, weight: .semibold))
                   //         .frame(width: 172, height: 32)
                   //         .foregroundColor(.blue)
                   //         .background(Color.white) // 按钮背景为白色
                   //         .cornerRadius(6)
                   //         .overlay(
                   //             RoundedRectangle(cornerRadius: 6)
                   //                 .stroke(Color.blue, lineWidth: 1)
                   //         )
                   // }
                }
            }
        }
    }
}

struct ProfileActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileActionButtonView(viewModel: ProfileViewModel(user: dev.user))
    }
}
