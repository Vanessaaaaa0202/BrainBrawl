import SwiftUI

struct FeedView: View {
    @StateObject var viewModel = FeedViewModel()
    @State private var showCommentSuccessNotification = false
    @StateObject var commentNotificationManager = CommentNotificationManager() // 创建环境对象
    @State private var notificationOffset = -UIScreen.main.bounds.height
    // 定义进度条的状态
    @State private var showProgressBar = false
    @State private var uploadProgress: CGFloat = 0.0
    @State private var showCompletionMessage = false
    @State private var uploadComplete = false
    @State private var progressBarOffset: CGFloat = 0

    
    
    
    func showCommentNotification() {
        print("Showing comment notification in FeedView")
        self.showCommentSuccessNotification = true
        // 几秒钟后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCommentSuccessNotification = false
        }
    }
    
    var body: some View {
        ZStack{
            NavigationStack {
                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(viewModel.posts) { post in
                            FeedCell(post: post)
                        }
                        if !viewModel.isLastPage {
                            ProgressView()
                                .onAppear {
                                    viewModel.loadMorePosts()
                                }
                        }
                    }
                    .padding(.top)
                }
                .toolbar {

                    ToolbarItem(placement: .navigationBarLeading) {
                        Image("Brainbrawlsign")
                    }
 /*
                     ToolbarItem(placement: .navigationBarTrailing) {
                     NavigationLink(
                     destination: ConversationsView(),
                     label: {
                     Image(systemName: "paperplane")
                     .imageScale(.large)
                     .scaledToFit()
                     .foregroundColor(Color.theme.systemBackground)
                     })
                     }*/
                }
                //删除
                /*
                 //无法点击之后立马发送
                 .onAppear(){
                 viewModel.refreshData() // 当视图出现时刷新数据
                 }*/
                //
                //.navigationTitle("")
                //.navigationBarTitleDisplayMode(.inline)
                .refreshable {
                    viewModel.refreshPosts()
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
                
            }.environmentObject(commentNotificationManager) // 传递给所有子视图
            
            
            //Progress Bar
            GeometryReader{ geometry in
                ProgressBarView(
                    showProgressBar: $showProgressBar,
                    uploadProgress: $uploadProgress,
                    showCompletionMessage: $showCompletionMessage,
                    uploadComplete: $uploadComplete,
                    width: UIScreen.main.bounds.width * 0.97,
                    height: 20,
                    color1: .blue,
                    color2: .red,
                    imageName: "app_icon_58"
                )
                //.offset(y: -330)
                //.transition(.slide)
                .zIndex(1)
                .offset(y: geometry.safeAreaInsets.top*0.65)
            }
            
            if commentNotificationManager.showCommentNotification {
                let notificationBackgroundColor: Color = commentNotificationManager.commentType == .red ? Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1) : Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1)
                
                Text("Comment posted successfully")
                    .frame(width:300)
                    .padding()
                    .background(notificationBackgroundColor)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .offset(y: notificationOffset)
                // 使用 spring 动画来给通知一个弹簧效果
                    .animation(.spring(response: 0.9, dampingFraction: 0.8), value: notificationOffset)
                    .zIndex(1)
                    .onAppear {
                        withAnimation {
                            notificationOffset = -330// 初始从屏幕顶部下方20单位处开始
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                notificationOffset = -UIScreen.main.bounds.height // 移回屏幕顶部
                            }
                        }
                    }
                    .onDisappear {
                        // 重置偏移量，以便下次使用
                        notificationOffset = -UIScreen.main.bounds.height
                    }
            }
        }
        .onAppear {
            setupProgressNotifications()
        }
    }
    
    
    private func setupProgressNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowUploadProgress"), object: nil, queue: .main) { _ in
            showProgressBar = true
            uploadProgress = 0.0 // 初始化进度
            // 这里可以添加逻辑来模拟或更新上传进度
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("HideUploadProgress"), object: nil, queue: .main) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                self.progressBarOffset = -100 // 或任何足够将进度条移出视图的数值
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showProgressBar = false
                self.uploadComplete = true
            }
        }
    }
    
}
    
struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        Image("24brain")

            
    }
}
