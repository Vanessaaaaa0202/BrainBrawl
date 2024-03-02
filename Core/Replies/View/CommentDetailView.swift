import SwiftUI

struct CommentDetailView: View {
    let comment: Comment
    var targetReply: Reply?
    var replies: [Reply]  // 现在将回复列表作为参数传递
    let post: Post  // 假设您有一个有效的 Post 对象

    var body: some View {
        VStack {
            // 显示评论
            CommentCell(comment: comment, post: post, viewModel: CommentViewModel(post: post))  // 确保传递有效的 Post 对象

            // 显示回复，如果有 targetReply，则置顶显示
            ForEach(sortedReplies) { reply in
                ReplyCell(comment: comment, post: post, reply: reply, viewModel: ReplyViewModel(postId: comment.postId, commentId: comment.id ?? "", commentOwnerUid: comment.commentOwnerUid))
            }
        }
    }
    
    var sortedReplies: [Reply] {
        // 如果有 targetReply，则将其置顶显示
        guard let targetReply = targetReply else {
            return replies
        }
        return [targetReply] + replies.filter { $0.id != targetReply.id }
    }
}



