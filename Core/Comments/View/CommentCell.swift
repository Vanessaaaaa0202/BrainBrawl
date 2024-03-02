 //
//  CommentCell.swift
//  InstagramSwiftUITutorial
//  Created by Stephen Dowless on 1/1/21.
//

import SwiftUI
import Firebase

struct CommentCell: View {
    let comment: Comment
    var post: Post
    @ObservedObject var viewModel: CommentViewModel
    @State private var isNavigatingToReply = false
    @StateObject var replyViewModel: ReplyViewModel
    @State private var displayedRepliesCount = 3
    @State private var showMoreRepliesButton = false
    @State private var displayedReplies = [Reply]()
    var currentUserUid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    init(comment: Comment, post: Post, viewModel: CommentViewModel) {
        self.comment = comment
        self.post = post
        self.viewModel = viewModel
        self._replyViewModel = StateObject(wrappedValue: ReplyViewModel(postId: post.id ?? "", commentId: comment.id ?? "", commentOwnerUid: comment.commentOwnerUid))
    }

    var body: some View {
        VStack(alignment: .leading) {
            // 评论主体内容

            //第一行 用户信息
            HStack{
                //用户头像
                if let user = comment.user {
                    NavigationLink(value:user) {
                        CircularProfileImageView(user: comment.user, size: .xxSmall)
                            .overlay(
                                Circle()
                                    .fill(commentColor)
                                    .frame(width: 8, height: 8)
                                    .offset(x: -10, y: -31),
                                alignment: .bottomTrailing
                            )
                    }
                }

                if let user = comment.user {
                    NavigationLink(value:user) {
                        Text(comment.user?.username ?? "Unknown user")
                            .fontWeight(.semibold)
                            .font(.subheadline)
                    }
                }
                //发布日期
                Text(comment.timestamp.timestampString())
                    .foregroundColor(.gray)
                    .font(.caption)
                //间隔
                Spacer()
                // 点赞按钮
                HStack(spacing:3){
                    Button(action: {
                        Task {
                            await viewModel.toggleLike(for: comment.id ?? "")
                        }
                    }) {
                        Image(systemName: comment.likedBy.contains(currentUserUid) ? "heart.fill" : "heart")
                            .foregroundColor(comment.likedBy.contains(currentUserUid) ? .black : .gray)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Text("\(comment.likesCount)")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(minWidth:9, alignment:.leading)
                }
            }
            //.border(.red)
            
            //第二行 评论内容
            ExpandableText(postCaption: comment.commentText)
                .font(.caption)
                .padding([.leading], 36.5)
                .padding(.trailing,9)

            // 评论按钮
            NavigationLink(destination: ReplyView( comment: comment, viewModel: replyViewModel, onReplyPosted: {
                Task {
                    await replyViewModel.fetchReplies() // 在异步上下文中调用
                }
            }), isActive: $isNavigatingToReply) {
                EmptyView()
            }

            Button(action: {
                isNavigatingToReply = true
            }) {
                HStack{
                    Image(systemName: "bubble.left")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth:.infinity, alignment:.trailing)
                .padding(.top,8)
                
                }
            .buttonStyle(PlainButtonStyle())
           
            // 展示回复（如果有）
            // 检查 replies 数组是否不为空
            if !replyViewModel.replies.isEmpty {
            
                ForEach(replyViewModel.replies.prefix(displayedRepliesCount), id: \.self) { reply in
                    ReplyCell(comment: comment, post: post, reply: reply, viewModel: replyViewModel)
                }
            }
            
            if replyViewModel.replies.count > 3 && showMoreRepliesButton && !replyViewModel.replies.isEmpty {
                Button("Show more replies") {
                    let remainingReplies = replyViewModel.replies.count - displayedRepliesCount
                    if remainingReplies > 5 && !replyViewModel.replies.isEmpty  {
                        displayedRepliesCount += 5
                    } else {
                        displayedRepliesCount += remainingReplies
                    }
                    // 更新按钮的显示状态
                    showMoreRepliesButton = replyViewModel.replies.count > displayedRepliesCount
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
                .padding(.trailing)
            }

            Divider()
        }
        .padding(.horizontal,3)
        //.padding(.top,4)
        .onAppear {
            Task {
                await replyViewModel.fetchReplies() // 异步加载回复数据
                // 确保以下状态更新发生在数据加载完成之后
                DispatchQueue.main.async {
                    displayedRepliesCount = min(replyViewModel.replies.count, 3)  // 初始显示最多3条回复
                    showMoreRepliesButton = replyViewModel.replies.count > 3
                }
            }
        }

        .onChange(of: replyViewModel.replies) { _ in
            showMoreRepliesButton = replyViewModel.replies.count > displayedRepliesCount
        }
    }

    var commentColor: Color {
        switch comment.colorType {
        case .red:
            return Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1)
        case .blue:
            return Color(red:25/255.0, green:146/255.0, blue:233/255.0, opacity:1)
        // 默认颜色或其他情况
        default:
            return .gray
        }
    }
}

