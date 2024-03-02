//
//  NotificationCell.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//

import SwiftUI
import Kingfisher

struct NotificationCell: View {
    @ObservedObject var viewModel: NotificationCellViewModel
    @Binding var notification: Notification
    @State private var isLoadingUser = false
    @State private var navigateToCommentsView = false

    //@State private var showCommentsView = false // 状态变量控制导航
    
    var isFollowed: Bool {
        return notification.isFollowed ?? false
    }
    
    init(notification: Binding<Notification>) {
        self.viewModel = NotificationCellViewModel(notification: notification.wrappedValue)
        self._notification = notification
    }
    
    var body: some View {
        VStack {
            // 隐藏的 NavigationLink
           // NavigationLink(destination: destinationView(), isActive: $navigateToCommentsView) {
           //     EmptyView()
           // }
           // .hidden()

            // 用户交互的 Button
            notificationContent
           
        }
        .simultaneousGesture(TapGesture().onEnded {
            // Perform your action here
            Task{ await viewModel.markNotificationAsViewed(notificationId: notification.id ?? "")}
        })
}

    @ViewBuilder
    //private func destinationView() -> some View {
    //    // 根据实际情况提供目的地视图
    //    if let post = notification.post, let postId = notification.postId {
    //        CommentsView(post: post, targetCommentId: notification.targetCommentId, targetReplyId: notification.targetReplyId)
    //    } else {
    //        // 提供一个备选视图，以防 post 信息不完整
    //        Text("Detail View Not Available")
    //    }
    //}
    // 抽取出 NotificationCell 的主要内容
    private var notificationContent: some View {
        VStack(alignment: .leading) {
            NavigationLink(value:notification){
                HStack {
                    if let user = notification.user {
                        if notification.type == .follow {
                            userProfileLink(user: user)
                            Spacer()
                            FollowButton(isFollowed: isFollowed, viewModel: viewModel, notification: $notification)
                        } else {
                            userProfileLink(user: user)
                            Spacer()
                            if notification.postId != nil{
                                // 只有在 post 图片存在的情况下显示图片
                                if let post = notification.post, !post.imageUrl.isEmpty {
                                    ZStack{
                                        NavigationLink(value:notification){
                                            postImage(post: post)
                                        }
                                        if notification.viewed == false {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 6, height: 6)
                                                .offset(x:28,y:0)
                                        }
                                    }
                                }else{
                                    // Here we handle the case where the post has been deleted
                                    Text("Post has been deleted")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }else{
                                // Here we handle the case where the post has been deleted
                                Text("Post has been deleted")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }}
            NavigationLink(value:notification){
                notificationText
            }.padding(.bottom,5)
            
            Divider()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func userProfileLink(user: User) -> some View {
        NavigationLink(value:user) {
            CircularProfileImageView(user: user, size: .xSmall)
        }
        
        if let post = notification.post {
            NavigationLink(value:notification){
                userInfoView(user: user)
            }
        }else{
            userInfoView(user: user)
        }
    }
    
    @ViewBuilder
    private func postImage(post: Post) -> some View {
        KFImage(URL(string: post.imageUrl))
            .resizable()
            .frame(width: 40, height: 40)
            .cornerRadius(8)
            .clipped()
    }
    
    @ViewBuilder
    private var notificationText: some View {
        if let postId = notification.postId, postId != "", let post = notification.post, !post.imageUrl.isEmpty, let notificationText = notification.text, !notificationText.isEmpty {
            Text(notificationText)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .frame(maxWidth:.infinity, alignment:.leading)
                .padding(.top, -5)
                .padding(.leading, 44)
                .multilineTextAlignment(.leading)
                .lineLimit(5)
                
        }
    }

    // User information view with conditional red dot for unread notifications
    @ViewBuilder
    private func userInfoView(user: User) -> some View {
        HStack {
            Text(user.username)
                .font(.system(size: 14, weight: .semibold))
            + Text(notification.type.notificationMessage)
                .font(.system(size: 14))
            + Text(" \(notification.timestamp.timestampString())")
                .foregroundColor(.gray).font(.system(size: 12))
            // Add a red dot for unread notifications
         //   if notification.viewed == false { // If `viewed` is false
         //       Circle()
         //           .fill(Color.red)
         //           .frame(width: 8, height: 8)
         //           .offset(x: 5, y: -10) // Adjust positioning as needed
         //   }
        }
        .multilineTextAlignment(.leading)
    }

}

struct FollowButton: View {
    var isFollowed: Bool
    var viewModel: NotificationCellViewModel
    @Binding var notification: Notification
    
    var body: some View {
        Button(action: {
            isFollowed ? viewModel.unfollow() : viewModel.follow()
            notification.isFollowed?.toggle()
        }, label: {
            Text(isFollowed ? "Following" : "Follow")
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 100, height: 32)
                .foregroundColor(isFollowed ? .black : .white)
                .background(isFollowed ? Color.white : Color.blue)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray, lineWidth: isFollowed ? 1 : 0)
                )
        })
    }
}
