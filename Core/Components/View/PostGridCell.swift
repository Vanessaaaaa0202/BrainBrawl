//
//  PosrGridCell.swift
//  BrainBrawl
//
//  Created by sk_sunflower@163.com on 2023/12/18.
//

import SwiftUI
import Kingfisher

struct PostGridCell: View {
    @ObservedObject var viewModel: PostGridCellViewModel
    @ObservedObject var profileViewModel: ProfileViewModel
    @State private var showingDeleteAlert = false  // 新增状态变量
    @State private var navigateToRedCommentView: Bool = false
    @State private var isPostAvailable: Bool = true  // 新增状态变量
    
    //Click计数用
    @State private var redClicks: Int = 0
    @State private var blueClicks: Int = 0
    //评论用
    @State private var showRedCommentInput: Bool = false
    @State private var showBlueCommentInput: Bool = false
    var showColorCommentsButtons: Bool
    var onDelete: (() -> Void)? // 添加一个可选的闭包参数
    
    var totalClicks: Int {
        return redClicks + blueClicks
    }
    var didLike: Bool { return viewModel.post.didLike ?? false }
    
    //RedBlue Bar
    var blueCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfBlueComments) / CGFloat(viewModel.totalComments)
        } else {
            return 0.5 // 没有评论时，返回默认值 0.5
        }
    }
    
    var redCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfRedComments) / CGFloat(viewModel.totalComments)
        } else {
            return 0.5 // 没有评论时，返回默认值 0.5
        }
    }
    
    
    
    init(post: Post, profileViewModel: ProfileViewModel, showColorCommentsButtons: Bool = true, onDelete: (() -> Void)? = nil) {
        self.viewModel = PostGridCellViewModel(post: post)
        self.profileViewModel = profileViewModel
        self.showColorCommentsButtons = showColorCommentsButtons
        self.onDelete = onDelete
    }
    
    private var user: User? {
        print(viewModel.post.user)
        return viewModel.post.user
    }
    
    private var post: Post {
        return viewModel.post
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        ProfileImage(profileViewModel: profileViewModel, size: .xSmall)
                        Text(profileViewModel.user.username)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.theme.systemBackground)
                        
                        Spacer()
                        
                        if profileViewModel.user.isCurrentUser{
                            Button(action: {
                                Task {
                                    self.showingDeleteAlert = true  // 显示删除确认对话框
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.red) // 您可以选择一个合适的颜色
                                    .padding(.top,1.5)
                            }
                            .padding(.trailing,4) // 根据您的布局需要可能要调整这个值
                        }
                    }.padding(.leading,1.5)
                    //}
                    
                    
                    Text(post.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color.theme.systemBackground)
                        .padding([.leading, .trailing],2)
                        .multilineTextAlignment(.leading)
                }
                .padding([.leading], 8)
                //Spacer() // 这个Spacer会把内容推向左边和右边
                
                
                //}
                //.padding([.leading, .bottom], 8)
                
                //NavigationLink(destination: CommentsView(post: post)) {
                NavigationLink(value:post){
                    VStack {
                        DebatePowerBar(
                            pro: blueCommentRatio,
                            neutral: CGFloat(0),
                            contra: redCommentRatio,
                            proRatio: blueCommentRatio,
                            contraRatio: redCommentRatio,
                            isLoadingBar: viewModel.isLoadingBar  // Pass the isLoading state
                        )                            //.frame(height: 20) // 确保与FeedCell中的高度一致
                        .padding(.top, 0)  // 确保与FeedCell中的padding一致
                        .padding([.bottom], 7)
                        
                        KFImage(URL(string: post.imageUrl))
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.97 )
                            .frame(maxHeight: UIScreen.main.bounds.width * 0.97 * 1.2) // 设定图片的最大高度
                            .cornerRadius(24)
                            .clipped()
                    }
                }
                
                NavigationLink(value:post){
                    HStack{
                        Text(post.caption)
                        .multilineTextAlignment(.leading)
                    }
                        .lineLimit(5)
                        .padding(.horizontal, 10)
                }
                
                
                HStack(spacing: 2) {
                    Button(action: {
                        Task {
                            viewModel.post.didLike ?? false ? try await viewModel.unlike() : try await viewModel.like()
                        }
                    }, label: {
                        Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
                            .resizable()
                        //.foregroundColor(viewModel.post.didLike ?? false ? .black : .primary)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding(3)
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    NavigationLink(value: SearchViewModelConfig.likes(viewModel.post.id ?? "")) {
                        Text(viewModel.likeString)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.trailing, 6)
                            .frame(minWidth:16, alignment:.leading)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Confirm Deletion"),
                            message: Text("Are you sure you want to delete this post?"),
                            primaryButton: .destructive(Text("Delete")) {
                                Task {
                                    await viewModel.deletePostAndRelatedData()
                                    onDelete?()
                                }
                            },
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }
                    //MARK: share功能先注释掉
                    // Button(action: {}, label: {
                    //     Image(systemName: "square.and.arrow.up")
                    //         .resizable()
                    //         .scaledToFill()
                    //         .frame(width: 20, height: 20)
                    //         .font(.system(size: 25))
                    //         .padding(4)
                    //         .foregroundColor(Color.theme.systemBackground)
                    // })
                    
                    NavigationLink(value:post){
                        HStack {
                            Image(systemName: "flame")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(.trailing,-4)
                                .padding(.leading,2)
                            
                            Text("\(viewModel.formattedTotalComments)")
                                .font(.system(size: 14, weight: .semibold))
                            
                            Spacer() // 使得点击区域延伸到整个空白处
                        }
                        .contentShape(Rectangle()) // 使得整个HStack部分都能响应点击
                        .background(Color.clear.opacity(0.3)) // 临时的背景颜色，以便查看区域
                    }
                    
                    Spacer()
                    
                }
                .padding(.leading, 4)
                
                //Text(post.timestamp.timestampString())
                //    .font(.system(size: 14))
                //    .foregroundColor(.gray)
                //    .padding(.leading, 8)
                //    .padding(.top, -2)
                NavigationLink(value:post){
                    HStack{
                        Text(post.timestamp.timestampString())
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        Spacer()
                    }
                }
                Divider()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //与CircularProfileImageView一样 但可以满足实时更新user的更改
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
