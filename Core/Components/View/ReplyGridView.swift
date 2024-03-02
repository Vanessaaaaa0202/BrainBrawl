import SwiftUI
import Firebase
import Kingfisher

struct ReplyGridView: View {
    @ObservedObject var viewModel: ReplyGridViewModel
    var profileViewModel: ProfileViewModel  // 新增 profileViewModel
    
    var currentUserUid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        ScrollView {
            if viewModel.isLoading {
                Text("Loading")
                    .foregroundColor(.gray)
                    .padding(.top, 90)
                ProgressView()
                    .scaleEffect(1, anchor: .center)
                    .padding(.top)
            } else {
                if viewModel.mainComments.isEmpty {
                    // 当没有帖子时显示的消息
                    Text("No Replies")
                        .padding(.top, 100)
                        .font(.title)
                        .foregroundColor(.gray)
                }else{
                    LazyVStack {
                        ForEach(Array(viewModel.mainComments.enumerated()), id: \.element.self) { (index, comment) in
                            VStack(alignment: .leading) {
                                
                                HStack{
                                    if let user = comment.user {
                                        ProfileImage(profileViewModel: profileViewModel, size: .xxSmall)
                                            .overlay(
                                                Circle()
                                                    .fill(self.commentColor(for: comment))
                                                    .frame(width: 8, height: 8)
                                                    .offset(x: -10, y: -31),
                                                alignment: .bottomTrailing
                                            )
                                    }
                                    
                                    HStack {
                                        if let post = viewModel.posts[comment.postId]{
                                            NavigationLink(destination: CommentsView(post: post, targetCommentId: nil, targetReplyId: nil)){
                                                Text(viewModel.postTitles[comment.postId] ?? "No Title")
                                                    .fontWeight(.semibold)
                                                    .lineLimit(1)
                                                    .padding(.bottom, 8) // 在标题下方添加间距
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
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
                                    }
                                }
                                
                                
                                    
                                    Text(comment.commentText)
                                        .foregroundColor(.black) // 或者使用 .primary 以使用默认文本颜色
                                        .font(.caption)
                                        .padding([.leading], 36.5)
                                        .padding(.trailing,9)
                                    
                                   /* HStack {
                        
                                        Image(systemName: "flame.fill") // Use your flame image here
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.orange)
                                        
                                        Text("\(comment.likedBy.count + (viewModel.commentReplies[comment.id ?? ""]?.count ?? 0))")
                                            .font(.caption)
                                            .foregroundColor(.black)
                                    }*/
                                Text(" \(comment.timestamp.timestampString())")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                    .frame(maxWidth:.infinity, alignment: .leading)
                                
                            }.padding(.horizontal,3)
                                .padding(.top,8)
                           // .padding([.horizontal, .top])
                            
            
                                
                            
                            
                            if index < viewModel.mainComments.count - 1 {
                                Divider()
                            } else {
                                Divider()
                                
                                Text("—— The End ——")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                                    .padding(.top, 10)
                            }
                        }
                        .padding(.bottom, 5)
                    }
                }
            }
        }
    }
    private func commentColor(for comment: Comment) -> Color {
        switch comment.colorType {
        case .red:
            return Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1)
        case .blue:
            return Color(red:25/255.0, green:146/255.0, blue:233/255.0, opacity:1)
        }
    }
    
    // ProfileImage view definition
    struct ProfileImage: View {
        @ObservedObject var profileViewModel: ProfileViewModel
        let size: ProfileImageSize
        
        var body: some View {
            if let imageUrl = profileViewModel.user.profileImageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: size.dimension, height: size.dimension)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: size.dimension, height: size.dimension)
                    .foregroundColor(Color(.systemGray4))
            }
        }
    }
}
