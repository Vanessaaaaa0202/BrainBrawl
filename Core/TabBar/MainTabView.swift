//
//  MainTabView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/26/20.
//

import SwiftUI

struct MainTabView: View {
    let user: User
    @Binding var selectedIndex: Int
    @StateObject var profileViewModel: ProfileViewModel // 移动到这里声明
    @StateObject var postGridViewModel: PostGridViewModel
    @StateObject var notificationsViewModel = NotificationsViewModel() // 添加这个属性
    @State private var showNotificationBadge = false // 用于控制是否显示通知徽章
    //let onUploadComplete: () -> Void


    // 初始化 profileViewModel
    init(user: User, selectedIndex: Binding<Int>) {
            self.user = user
            self._selectedIndex = selectedIndex
            self._profileViewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
            self._postGridViewModel = StateObject(wrappedValue: PostGridViewModel(config: .profile(user)))
        }
    
    
    var body: some View { 

            TabView(selection: $selectedIndex) {
                FeedView()
                    .tabItem {
                        Image(systemName: selectedIndex == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedIndex == 0 ? .fill : .none)
                    }
                    .onAppear { selectedIndex = 0 }
                    .tag(0)
                
                SearchView()
                    .tabItem { Image(systemName: "magnifyingglass") }
                    .onAppear { selectedIndex = 1 }
                    .tag(1)
                
                UploadMediaView(tabIndex: $selectedIndex, onUploadComplete: {
                    self.selectedIndex = 0 // 返回到主页面的标签（假设是0）
                })
                .tabItem { Image(systemName: "plus") }
                .onAppear { selectedIndex = 2 }
                .tag(2)
                
                NotificationsView(viewModel: notificationsViewModel)
                    .tabItem {
                        if notificationsViewModel.unreadCount > 0 {
                            // 有未读通知时
                            VStack {
                                Image(systemName: selectedIndex == 3 ? "bell.badge.fill" : "bell.badge")
                                    .environment(\.symbolVariants, selectedIndex == 3 ? .fill : .none)
                                Text("\(notificationsViewModel.unreadCount)")
                            }
                            .foregroundColor(.red)
                        }
                            // 没有未读通知时*/
                        Image(systemName: selectedIndex == 3 ? "bell.fill" : "bell")
                            .environment(\.symbolVariants, selectedIndex == 3 ? .fill : .none)
                        
                    }
                    .onAppear { selectedIndex = 3 }
                    .tag(3)


                
                
                CurrentUserProfileView(user: user, postGridViewModel: postGridViewModel)
                    .environmentObject(profileViewModel) // 将 ProfileViewModel 作为环境对象传递
                    .tabItem {
                        Image(systemName: selectedIndex == 4 ? "person.fill" : "person")
                            .environment(\.symbolVariants, selectedIndex == 4 ? .fill : .none)
                    }
                    .onAppear {
                        selectedIndex = 4
                        profileViewModel.refreshUserStats()
                    }// 当选项卡出现时刷新用户数据}
                    .tag(4)
            }
            .onReceive(notificationsViewModel.$notifications) { notifications in
                showNotificationBadge = notifications.contains { /*$0.viewed == nil ||*/  $0.viewed == false } // Show badge if any notification is new
            }
            .tint(Color.theme.systemBackground)
        
    }
        

    var messageLink: some View {
        NavigationLink(
            destination: ConversationsView(),
            label: {
                Image(systemName: "paperplane")
                    .resizable()
                    .font(.system(size: 20, weight: .light))
                    .scaledToFit()
                    .foregroundColor(.black)
            })
    }
}
