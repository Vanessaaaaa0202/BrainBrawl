//
//  UploadMediaView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 5/4/23.
//

import SwiftUI

struct UploadMediaView: View {
    @State private var titleText = ""
    @State private var captionText = ""
    @State private var imagePickerPresented = false
    @State private var uploadComplete = false
    @Binding var tabIndex: Int
    @StateObject var viewModel = UploadPostViewModel()
    @State private var keyboardHeight: CGFloat = 0
    // 假设您已经有一个用于控制键盘显示的状态变量
    @State private var isFirstResponder = false
    //@Environment(\.presentationMode) var presentationMode
    var onUploadComplete: (() -> Void)?
    @State private var textCount = 0  // 添加状态变量来存储字数或单词数
    
    
    var isShareButtonDisabled: Bool {
            let trimmedTitleText = titleText.trimmingCharacters(in: .whitespaces)
            let isOverLimit = titleText.count > 300 // 假设限制应用于标题文
            return viewModel.profileImage == nil || trimmedTitleText.isEmpty || isOverLimit
       }
    
    var body: some View {
        VStack {
            HStack{
                Button(action: {
                    clearForm()
                    tabIndex = 0
                }) {
                    
                    Text("Cancel")
                        //.fontWeight(.medium)
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                
                Spacer()
                
                Button(action: {
                    onUploadComplete?()
                    uploadPost()
                    //startUpload()
                }) {
                    Text("Post")
                        .fontWeight(.medium)
                        .foregroundColor(viewModel.profileImage != nil && !titleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.white : Color.gray) // Dynamic foreground color based on comment content
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        //.foregroundColor(.white)
                        .background(Capsule().fill(viewModel.profileImage != nil &&
                                    !titleText.trimmingCharacters(in: .whitespaces).isEmpty
                                                   ? LinearGradient(gradient: Gradient(colors: [Color(red:25/255.0, green:146/255.0, blue:233/255.0).opacity(0.75), Color(red:249/255.0, green:97/255.0, blue:103/255.0, opacity:0.75)]), startPoint: .trailing, endPoint: .leading) : LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemGray5).opacity(1), Color(UIColor.systemGray5)]), startPoint: .trailing, endPoint: .leading)))  // Use titleText to determine background color
                        //.cornerRadius(5)  // Apply the corner radius to the Text
                }
                .disabled(isShareButtonDisabled)  // Disable the button based on titleText and profileImage
            }
            .padding(.bottom)
            .padding(.leading,2)
            
            VStack {
                // 图片添加按钮或已选图片的展示
                if let image = viewModel.profileImage {
                    ZStack(alignment: .topTrailing) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .cornerRadius(10)
                            .clipped()
                        
                        Button(action: {
                            // 删除图片的动作
                            viewModel.selectedImage = nil
                            viewModel.profileImage = nil
                        }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(Color.gray)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x:-2,y:4)
                        }
                        //.padding(5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 96, alignment: .leading)
                } else {
                    Button(action: {
                        imagePickerPresented.toggle()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius:10)
                                .fill(Color(UIColor.systemGray3))
                                .frame(width: 96, height: 96)
                                //.cornerRadius(10)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.largeTitle)
                        }
                    }.frame(maxWidth: .infinity,maxHeight: 96, alignment: .leading)
                }
                
                
                HStack {
                    TextField("Enter a YES or No question...", text: $titleText)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .cornerRadius(5)
                        .submitLabel(.done)
                        .onChange(of: titleText) { newValue in
                            // 调用ViewModel的方法来处理文本更新
                            let processingResult = viewModel.processText(newValue, limit: 300, inputSource: .uploadPostTitle)
                            
                            // 检查处理后的wordCount是否超过限制
                            if processingResult.wordCount <= 300 {
                                // 如果没有超过限制，更新ViewModel的titleText
                                DispatchQueue.main.async { // 确保在主线程上更新 UI
                                    self.titleText = processingResult.newText // 更新视图中的文本
                                    self.viewModel.currentWordCount = processingResult.wordCount // 同步更新 ViewModel 中的单词计数
                                }
                            } else {
                                // 如果超过限制，生成触觉反馈
                                let generator = UINotificationFeedbackGenerator()
                                generator.notificationOccurred(.error)
                                // 阻止文本更新：已经在处理结果中处理了，这里不再需要额外操作
                            }
                        }


                    
                    Spacer() // Pushes the following items to the trailing edge.
                    
                    Text("\(300 - viewModel.currentWordCount) characters left")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding() // Add padding to the HStack for better spacing
                
                
                Divider()
            }
            
            TextView(text: $captionText, isFirstResponder: .constant(false), count: $textCount, placeholder: "Enter more description...(Character limit of 3000)", inputSource: .uploadMedia)
                .frame(minHeight: 100, maxHeight: .infinity)
                //.foregroundColor(Color(UIColor.systemGray3))
                .padding(.horizontal, -4.5)
                .background(Color.clear)
            // 显示当前的字数或单词数
            if textCount > 2700 {
                Text("Characters Limit: \(3000 - textCount)")
                    .font(.caption)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            
            Spacer()
        }
        .onAppear {
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
    
        //.ignoresSafeArea(.keyboard)
        .toolbar(.hidden, for: .tabBar)
        .padding()
        .photosPicker(isPresented: $imagePickerPresented, selection: $viewModel.selectedImage)
        .onDisappear {
            //clearForm()
        }
    }



    private func clearForm() {
        captionText = ""
        titleText = ""
        viewModel.selectedImage = nil
        viewModel.profileImage = nil
    }
    
    private func uploadPost() {
        NotificationCenter.default.post(name: .init("ShowUploadProgress"), object: nil)
        Task {
            try await viewModel.uploadPost(title: titleText, caption: captionText)
            clearForm()
            NotificationCenter.default.post(name: .init("HideUploadProgress"), object: nil)
        }
    }
}

struct UploadMediaView_Previews: PreviewProvider {
    static var previews: some View {
        UploadMediaView(tabIndex: .constant(0))
    }
}

