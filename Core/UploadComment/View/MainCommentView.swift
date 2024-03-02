import Foundation
import SwiftUI

enum SourceView {
    case feedView
    case commentsView
}

struct MainCommentView: View {
    @State var comment: String = ""  // 用于存储评论输入
    @State private var isFirstResponder = true
    @State private var delayedFirstResponder = false  // 用于控制延迟弹出键盘
    @StateObject var viewModel: MainCommentViewModel
    let post: Post  // 让我们保存对post的引用，以便在视图中使用
    let sourceView: SourceView
    let onCommentSuccessFromFeed: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var commentNotificationManager: CommentNotificationManager
    @State private var navigateToCommentsView: Bool = false
    @State private var shouldNavigate = false
    @State private var textCount = 0  // 添加状态变量来存储字数或单词数


    init(post: Post, commentType: Comment.CommentColorType, sourceView: SourceView, onCommentSuccessFromFeed: @escaping () -> Void) {
        self.post = post
        self.sourceView = sourceView
        self.onCommentSuccessFromFeed = onCommentSuccessFromFeed
        self._viewModel = StateObject(wrappedValue: MainCommentViewModel(post: post, commentColorType: commentType))
    }

    
    
    var body: some View {
        VStack {
            // Top section with user profile, color dot and post title
            HStack {
                // User profile with colored dot
                VStack(alignment: .center) {
                    CircularProfileImageView(user: post.user, size: .xSmall)
                        .overlay(
                            Circle()
                                .fill(viewModel.commentColor)
                                .frame(width: 10, height: 10)
                                .offset(x: -13, y: -39),
                            alignment: .bottomTrailing
                        )
                }.padding(.trailing,5)
                    .padding(.leading,1)
                //Spacer()
                // Post title
                Text(post.title)  // Using the post's title directly
                    .font(.headline)
                
                // Post button
               // MARK: 这个按钮换位置到顶部
            
              // NavigationLink(destination: CommentsView(post: post)) {
              //     Button(action: uploadMainComment) {
              //         Text("Post")
              //             .foregroundColor(viewModel.commentColor)
              //             .padding(.horizontal, 12)
              //             .padding(.vertical, 5)
              //             .background(Capsule().stroke(viewModel.commentColor))
              //      }
              //  }
            }
            .frame(maxWidth: .infinity,alignment:.leading)
            //.border(.red)
            .padding(.horizontal)
            .padding(.top,24)

            // Comment input area
            //TextField("Enter your comment...", text: $comment)
            TextView(text: $comment, isFirstResponder: $delayedFirstResponder, count: $textCount, placeholder: "Enter your comment...", inputSource: .uploadCommentOrReply)
                .frame(minHeight: 100, maxHeight: .infinity)
                .foregroundColor(.primary)
                .padding(.horizontal,13)
                .background(Color.clear)
                // No border needed, as commented out

            // 添加的计数器逻辑
            if textCount > 7500 {
                Text("Characters Limit: \(8000 - textCount)")
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Spacer()
        }
        .onAppear {
            // 延迟1秒弹出键盘
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self.delayedFirstResponder = true
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    if !comment.isEmpty {
                        uploadMainComment()
                        shouldNavigate = true
                        }
                    }) {
                        Text("Post")
                            .fontWeight(.medium)
                            .foregroundColor(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.white) // Dynamic foreground color based on comment content
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color(UIColor.systemGray5) : viewModel.commentColor))
                    }
                    .disabled(comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                NavigationLink(destination: CommentsView(post: post, targetCommentId: nil, targetReplyId: nil), isActive: $shouldNavigate) {
                                EmptyView()
                }
            }
        }
    }
    
    // 上传评论
    func uploadMainComment() {
        Task {
            do {
                try await viewModel.uploadMainComment(commentText: comment)
                comment = ""
                navigateToCommentsView = true
                print("Comment uploaded successfully")
                let commentType = viewModel.commentColorType == .red ? CommentNotificationManager.CommentType.red : CommentNotificationManager.CommentType.blue
                navigateBack()
                DispatchQueue.main.async { // 确保在主线程上执行
                        if sourceView == .feedView {
                            print("Calling onCommentSuccessFromFeed in MainCommentView")
                            //onCommentSuccessFromFeed()  // 通知 FeedView
                            commentNotificationManager.triggerCommentNotification(withType: commentType) // 触发通知
                        }
                    presentationMode.wrappedValue.dismiss() // Close the current view
                }
            } catch {
                print("Error uploading comment: \(error)")
            }
        }
    }
    
    private func navigateBack() {
         switch sourceView {
         case .feedView:
             print("Hello")
             
         case .commentsView:
             print("Hi")
         }
     }

}




