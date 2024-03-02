//
//  ProfileHeaderView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/27/20.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    @ObservedObject var viewModel: ProfileViewModel


    var body: some View {
        VStack {
            HStack {
                //GradientBorderCircularProfileImageView(user: viewModel.user, size: .xLarge)
                GradientBorderCircularProfileImageView(viewModel:viewModel, size: .xLarge)
                    .padding(.leading,18)

                HStack(spacing: 3) {
                    UserStatView(value: viewModel.user.stats?.posts, title: "Topics")
                    
                    NavigationLink(value: SearchViewModelConfig.followers(viewModel.user.id)) {
                        UserStatView(value: viewModel.user.stats?.followers, title: "Followers")
                    }
                    .disabled(viewModel.user.stats?.followers == 0)
                    
                    NavigationLink(value: SearchViewModelConfig.following(viewModel.user.id)) {
                        UserStatView(value: viewModel.user.stats?.following, title: "Following")
                    }
                    .disabled(viewModel.user.stats?.following == 0)
                }
                Spacer()
                
            }.frame(maxWidth:UIScreen.main.bounds.width)
            
            HStack() {
                if let bio = viewModel.user.bio {
                    Text(bio)
                        .font(.system(size: 12))
                        
                }
            }
            .frame(width:UIScreen.main.bounds.width*0.90, alignment: .leading)
            .padding(.top, 9)
            
            ProfileActionButtonView(viewModel: viewModel)
                .padding(.top, 9)
        }
        .frame(maxWidth:.infinity)
        .navigationDestination(for: SearchViewModelConfig.self) { config in
            UserListView(config: config)
        }
    }
}

// 这是一个私有的视图，只在ProfileHeaderView中使用
struct GradientBorderCircularProfileImageView: View {
    @ObservedObject var viewModel: ProfileViewModel
    let size: ProfileImageSize
    var lineWidth: CGFloat = 9 // 可以根据需要调整线宽

    var body: some View {
        // 载入图片
        Group {
            if let imageUrl = viewModel.user.profileImageUrl {
                KFImage(URL(string: imageUrl))
                    .resizable()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(Color(.systemGray4))
            }
        }
        .scaledToFill()
        .frame(width: size.dimension, height: size.dimension)
        .clipShape(Circle()) // 首先裁剪形状
        .background(
            Circle() // 在背景中添加边框
                .stroke(LinearGradient(gradient: Gradient(colors: [Color(red:25/255.0, green:146/255.0, blue:233/255.0).opacity(1), Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:1)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: lineWidth)
        )
        //.padding(lineWidth / 2) // 添加 padding 以考虑边框宽度
    }
}



struct ProfileHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(dev.users, id: \.id) { user in
            ProfileHeaderView(viewModel: ProfileViewModel(user: user))
        }
    }
}
