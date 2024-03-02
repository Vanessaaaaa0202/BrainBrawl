//
//  ReplyCell.swift
//  InstagramSwiftUITutorial
//
//  Created by Vanessa on 2023/11/11.
//

import SwiftUI
import Firebase

struct ReplyCell: View {
    let comment: Comment
    var post: Post
    var reply: Reply
    @State private var parentReplyUsername: String?
    @ObservedObject var viewModel: ReplyViewModel
    @State private var navigateToReplyView = false
    @State private var userCommentColorType: Comment.CommentColorType?
    
    var currentUserUid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                // 用户头像+名字
                if let user = reply.user {
                    NavigationLink(value:user) {
                        // 用户头像
                        CircularProfileImageView(user: user, size: .xxSmall)
                            .overlay(
                                Group {
                                    if let colorType = userCommentColorType {
                                        Circle()
                                            .fill(colorForType(colorType))  // 使用相应的颜色
                                            .frame(width: 8, height: 8)
                                            .offset(x: -10, y: -31)
                                    }
                                },
                                alignment: .bottomTrailing
                            )
                        Text(reply.user?.username ?? "Unknown user")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                    }
                }

                //发布时间
                Text(reply.timestamp.timestampString())
                    .foregroundColor(.gray)
                    .font(.caption)
                
                Spacer()
                // 点赞按钮
                HStack(spacing:3){
                    Button(action: {
                        Task {
                            await viewModel.toggleLike(for: reply.replyId ?? "")
                        }
                    }) {
                        Image(systemName: reply.likedBy.contains(currentUserUid) ? "heart.fill" : "heart")
                            .foregroundColor(reply.likedBy.contains(currentUserUid) ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    // 点赞数量
                    Text("\(reply.likesCount)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(minWidth:9, alignment:.leading)
                }
            }
            .task {
                userCommentColorType = await viewModel.getColorForUserInPost(userId: reply.replyOwnerUid, postId: post.id ?? "")
            }
            
            //第二行 回复对象的提示
            if let parentReplyId = reply.parentReplyId {
                // 显示 "Reply to [父回复的用户]"
                Text("Reply to \(parentReplyUsername ?? "Unknown"):")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .onAppear {
                        loadParentReplyUsername()
                    }
                    .padding([.leading], 36)
            }
               
            //第三行 评论内容
            ExpandableText(postCaption:reply.replyText)
                .font(.caption)
                .padding([.leading], 36.5)
                .padding(.trailing,9)
                
            
            //第四行 评论和分享图标放在左下角
//            HStack
            // 评论按钮，点击后导航到回复视图
            NavigationLink(destination: ReplyView(comment: comment, targetReply: reply, viewModel: ReplyViewModel(postId: post.id ?? "", commentId: comment.id ?? "", commentOwnerUid: comment.commentOwnerUid), onReplyPosted: {
                        // 这里是一个空闭包，因为在 ReplyCell 中可能不需要执行任何特定操作
                    }), isActive: $navigateToReplyView) {
                        EmptyView()
                    }

            Button(action: {
                navigateToReplyView = true
            }) {
                Image(systemName: "bubble.left")
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .frame(maxWidth:.infinity, alignment:.trailing)
            .padding(.top,8)
            //.padding(.leading, 346.5) // 与头像对齐 要更靠左一点
            //.padding(.top, 2)
            
        }
        .padding([.leading])  // 添加水平和顶部填充
        .padding( .top,9)
    }
    
    func loadParentReplyUsername() {
        // 检查是否存在 parentReplyId
        if let parentReplyId = reply.parentReplyId {
            // 从已加载的回复中寻找父回复
            if let parentReply = viewModel.replies.first(where: { $0.id == parentReplyId }) {
                // 更新用户名
                DispatchQueue.main.async {
                    self.parentReplyUsername = parentReply.user?.username
                }
            } else {
                print("Parent reply not found in loaded replies")
                DispatchQueue.main.async {
                    self.parentReplyUsername = "Unknown"
                }
            }
        }
    }
    
    private func colorForType(_ type: Comment.CommentColorType) -> Color {
        switch type {
        case .red:
            return Color(red: 249/255.0, green: 97/255.0, blue: 103/255.0, opacity: 1)
        case .blue:
            return Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1)
        }
    }
}
