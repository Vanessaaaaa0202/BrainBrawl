//
//  FeedCell.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//

import SwiftUI
import Kingfisher

struct FeedCell: View {
    @ObservedObject var viewModel: FeedCellViewModel
    @State private var navigateToComments: Bool = false
    @State private var redClicks: Int = 0
    @State private var blueClicks: Int = 0
    @State private var showRedCommentInput: Bool = false
    @State private var showBlueCommentInput: Bool = false
    @State private var navigateToBlueCommentView: Bool = false
    @State private var navigateToRedCommentView: Bool = false
    @State private var isPostAvailable: Bool = true  // 新增状态变量
    @State private var showingToast = false
    @State private var showingpicked = false
    var showColorCommentsButtons: Bool



    init(post: Post, showColorCommentsButtons: Bool = true) {
        self.viewModel = FeedCellViewModel(post: post)
        self.showColorCommentsButtons = showColorCommentsButtons
    }

    private var user: User? {
        return viewModel.post.user
    }

    private var post: Post {
        return viewModel.post
    }
    //MARK：为解决Invalid frame dimension的问题，排除除以0的特殊情况
    var blueCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfBlueComments) / CGFloat(viewModel.totalComments)
            } else {
                return 0.5
            }
        }
    var redCommentRatio: CGFloat {
        if viewModel.totalComments > 0 {
            return CGFloat(viewModel.numberOfRedComments) / CGFloat(viewModel.totalComments)
            } else {
                return 0.5
            }
        }

    var body: some View {
  
            ZStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        HStack {
                            if let user = user {
                                NavigationLink(value: user) {
                                    CircularProfileImageView(user: user, size: .xSmall)
                                    Text(user.username )
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.theme.systemBackground)
                                }
                            }
                            Spacer()
                            //==================================新增的三个点option
                            Menu {
                                
                                    Button(role: .destructive) {
                                        // Do something
                                    } label: {
                                        Label("Report", systemImage: "flag.fill")
                                    }
                           
                              //  //Block this user
                              //  Button {
                              //      // Do something
                              //  } label: {
                              //      Label("Block", systemImage: "eye.slash")
                              //  }
                                
                                //Share
                                Button {
                                    // Do something
                                } label: {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                }
                                
                                //Cancel
                                Button("Cancel", role: .destructive) {
                                    // Do something
                                }
                                
                            } label: {
                                Label("", systemImage: "ellipsis").padding(.bottom,6)
                            }
                            
                        }
                        .padding(.leading,1.5)
                        
                        NavigationLink(value:post){
                            
                            Text(post.title)
                            //.frame(maxWidth:.infinity,alignment:.leading)//@
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.theme.systemBackground)
                                .padding([.leading, .trailing],2)
                                .multilineTextAlignment(.leading)//@
                            
                        }
                        
                    }
                    .padding([.leading], 8)
                    
                    NavigationLink(value:post){
                        VStack {
                            DebatePowerBar(
                                pro: blueCommentRatio,
                                neutral: CGFloat(0),
                                contra: redCommentRatio,
                                proRatio: blueCommentRatio,
                                contraRatio: redCommentRatio,
                                isLoadingBar: viewModel.isLoadingBar  // Pass the isLoading state
                            )
                            
                            .padding(.top,0)
                            .padding([.bottom], 7)
                            //.padding([.leading, .trailing], 5)
                            
                            //}
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
                            .frame(maxWidth:.infinity,alignment:.leading)
                            .multilineTextAlignment(.leading)
                        }
                            .lineLimit(5)
                            .padding(.horizontal, 10)
                    } //@
                    
                    
                    HStack(spacing: 2) {
                        Button(action: {
                            Task {
                                viewModel.post.didLike ?? false ? try await viewModel.unlike() : try await viewModel.like()
                            }
                        }, label: {
                            Image(systemName: viewModel.post.didLike ?? false ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding(3)
                        })
                        .buttonStyle(PlainButtonStyle())
                        
                        
                        Text(viewModel.likeString)
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.trailing, 6)
                        //.frame(minWidth:16, alignment:.leading)//@
                        
                        NavigationLink(value:post){
                            HStack {
                                Image(systemName: "flame")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                //.padding(.trailing,-4) //@
                                    .padding(.leading,2)
                                
                                Text("\(viewModel.formattedTotalComments)")
                                    .font(.system(size: 14, weight: .semibold))
                                
                                Spacer() // 使得点击区域延伸到整个空白处
                            }
                            .contentShape(Rectangle()) // 使得整个HStack部分都能响应点击
                            .background(Color.clear.opacity(0.3)) // 临时的背景颜色，以便查看区域
                        }
                        
                        Spacer()
                        
                        if showColorCommentsButtons{
                            Image(systemName: "plus.bubble")
                                .foregroundColor(Color(red: 25/255.0, green: 146/255.0, blue: 233/255.0, opacity: 1))
                                .font(.system(size: 25))
                                .padding(6)
                                .onTapGesture {
                                    Task {
                                        let postExists = try await viewModel.checkPostExists(viewModel.post.id ?? "")
                                        if postExists && !viewModel.hascommentedfeed {
                                            navigateToBlueCommentView = true
                                            print("帖子存在")
                                        } else if !postExists {
                                            withAnimation {
                                                showingToast = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    showingToast = false
                                                }
                                            }
                                            print("帖子不存在")
                                        } else {
                                            withAnimation {
                                                showingpicked = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    showingpicked = false
                                                }
                                            }
                                        }
                                    }
                                }
                                .navigationDestination(isPresented: $navigateToBlueCommentView) {
                                    MainCommentView(post: viewModel.post, commentType: .blue, sourceView: .feedView, onCommentSuccessFromFeed: { })
                                }
                            
                            ///
                            Image(systemName: "plus.bubble")
                                .foregroundColor(Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1))
                                .font(.system(size: 25))
                                .padding(6)
                                .onTapGesture {
                                    Task {
                                        let postExists = try await viewModel.checkPostExists(viewModel.post.id ?? "")
                                        if postExists && !viewModel.hascommentedfeed {
                                            navigateToRedCommentView = true
                                            print("帖子存在")
                                        }  else if !postExists {
                                            withAnimation {
                                                showingToast = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    showingToast = false
                                                }
                                            }
                                            print("帖子不存在")
                                        } else {
                                            withAnimation {
                                                showingpicked = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                withAnimation {
                                                    showingpicked = false
                                                }
                                            }
                                        }
                                    }
                                }
                                .navigationDestination(isPresented: $navigateToRedCommentView) {
                                    MainCommentView(post: viewModel.post, commentType: .red, sourceView: .feedView, onCommentSuccessFromFeed: { })
                                }
                        }
                        
                    }
                    .padding(.leading, 4)
                    //.border(.red)
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
                //View for nonexist post
                if showingToast {
                    ToastView()
                        .transition(.opacity)
                        .zIndex(1) // 确保通知视图在最上层
                }
               //View for already commented post
                if showingpicked {
                    PickedView()
                        .transition(.opacity)
                        .zIndex(1) // 确保通知视图在最上层
                }
                
                // Toast message view
                if viewModel.showToast {
                    Text(viewModel.toastMessage)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        .cornerRadius(20)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.default, value: viewModel.showToast)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ToastView: View {
    var body: some View {
        Text("Post has been deleted")
            .padding()
            .background(Color.black)
            .foregroundColor(Color.white)
            .cornerRadius(20)
    }
}


struct PickedView: View{
    var body: some View {
        Text("You have picked your side")
            .padding()
            .background(Color.black)
            .foregroundColor(Color.white)
            .cornerRadius(20)
    }
}

