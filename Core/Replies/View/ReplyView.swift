//
//  ReplyView.swift
//  InstagramSwiftUITutorial
//
//  Created by Vanessa on 2023/11/11.
//

import SwiftUI
import Firebase

struct ReplyView: View {
    @Environment(\.presentationMode) var presentationMode
    var comment: Comment
    var targetReply: Reply?
    @ObservedObject var viewModel: ReplyViewModel
    @State private var replyText: String = ""
    var onReplyPosted: () -> Void  // 接收回调闭包
    @State private var isFirstResponder = true
    @State private var delayedFirstResponder = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var textCount = 0  // 添加状态变量来存储字数或单词数
    

    var body: some View {
            VStack {

                //MARK: 12.26 change
                VStack{
                VStack(alignment: .leading) {
                    if let targetReply = targetReply, let user = targetReply.user {
                        VStack(alignment:.leading) {
                            HStack{
                                CircularProfileImageView(user: user, size: .xxSmall)
                                Text((user.username ?? "Unknown user")+" :")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(.leading, -5)
                                Spacer()
                            }.padding(.leading, UIScreen.main.bounds.width * 0.015)
            
                            

                            ScrollView{  Text("\(targetReply.replyText)").multilineTextAlignment(.leading)
                                    .font(.caption)
                                    .padding(.horizontal,UIScreen.main.bounds.width * 0.015)
                                    //.padding(.top,-3)
                            }

                                //.border(.red)
                        }
                    } else {
                        
                        VStack(alignment:.leading) {
                            HStack{
                                //Text("Reply to").fontWeight(.semibold).foregroundStyle(Color(UIColor.systemGray2)).padding(.trailing,3)
                                    //.font(.system(size:28, weight: .semibold))
                                CircularProfileImageView(user: comment.user, size: .xxSmall)
                                Text((comment.user?.username ?? "Unknown user")+" :")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(.leading, -5)
                                Spacer()
                            }.padding(.leading, UIScreen.main.bounds.width * 0.015)
            
                            

                            ScrollView{  Text("\(comment.commentText)").multilineTextAlignment(.leading)
                                    .font(.caption)
                                    .padding(.horizontal,UIScreen.main.bounds.width * 0.015)
                                    //.padding(.top,-3)
                            }

                                //.border(.red)
                        }
                    }
                }
                .frame(maxWidth:.infinity,maxHeight: 150)
                    
                    Divider().frame(width:UIScreen.main.bounds.width * 0.97)
                //.border(.blue)
                // .padding()

                
                // 输入框
                    TextView(text: $replyText, isFirstResponder: $delayedFirstResponder, count: $textCount, placeholder: "Enter your comment...", inputSource: .uploadCommentOrReply)
                    .frame(width:UIScreen.main.bounds.width * 0.97)
                    .frame(minHeight: 100, maxHeight: .infinity)
                    .cornerRadius(8)
                    .padding([.horizontal,.bottom])
                    // 添加的计数器逻辑
                    if textCount > 7500 {
                        Text("Characters Limit: \(8000 - textCount)")
                            .font(.caption)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }.onAppear {
                    // 监听键盘显示和隐藏事件
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notif in
                        let value = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                        let height = value.height
                        keyboardHeight = height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                    }

                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                        keyboardHeight = 0
                    }
                }
                .onDisappear {
                    // 清除监听器，避免内存泄露
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self.delayedFirstResponder = true
            }
        }
        .navigationTitle("Reply to")
        //.ignoresSafeArea(.keyboard)
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    Task {
                        await viewModel.uploadReply(replyText: replyText, parentReplyId: targetReply?.id)
                        await viewModel.fetchReplies()
                        for reply in viewModel.replies {
                            print("Reply ID: \(reply.id)")
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }) {
                    Text("Post")
                        .fontWeight(.medium)
                        .foregroundColor(!replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white : Color.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(
                            !replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                                   ? LinearGradient(gradient: Gradient(colors: [Color(red:25/255.0, green:146/255.0, blue:233/255.0).opacity(0.75), Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:0.75)]), startPoint: .trailing, endPoint: .leading) : LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray5).opacity(1), Color(UIColor.systemGray5)]), startPoint: .trailing, endPoint: .leading)))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(replyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)  // Disable the button when replyText is empty
            }
        }
    }
}



