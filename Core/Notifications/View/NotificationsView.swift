import SwiftUI

struct NotificationsView: View {
    @StateObject var viewModel = NotificationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.notifications.isEmpty {
                    // 当没有通知时显示的视图
                    VStack {
                        Spacer()
                        Text("No Notifications")
                            .foregroundColor(.gray)
                            .font(.title2)
                        Spacer()
                    }
                } else {
                    // 当有通知时显示的ScrollView
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.notifications, id: \.id) { notification in
                                NotificationCell(notification: .constant(notification))
                                    .onAppear {
                                        if notification.id == viewModel.notifications.last?.id {
                                            viewModel.loadMoreNotifications()
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.markNotificationsAsViewed()
                        }
                    }) {
                        Text("Mark All Read").font(.system(size: 12, weight: .bold))
                    }
                }
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user)
            }
            .navigationDestination(for: SearchViewModelConfig.self) { config in
                UserListView(config: config)
            }
            .navigationDestination(for: Post.self) { selectedPost in
                CommentsView(post: selectedPost, targetCommentId: nil, targetReplyId: nil)
            }
            .navigationDestination(for: Notification.self) { selectedNoti in
                CommentsView(post: selectedNoti.post!, targetCommentId: selectedNoti.targetCommentId, targetReplyId: selectedNoti.targetReplyId)
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}
