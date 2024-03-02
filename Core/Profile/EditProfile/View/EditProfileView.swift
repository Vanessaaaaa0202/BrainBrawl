//
//  EditProfileView.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI
import Kingfisher
import PhotosUI

struct EditProfileView: View {
    @State private var username = ""
    @State private var editing = false
    @StateObject private var viewModel: EditProfileViewModel
    @Binding var user: User
    @Environment(\.dismiss) var dismiss
    
    init(user: Binding<User>) {
        self._user = user
        self._viewModel = StateObject(wrappedValue: EditProfileViewModel(user: user.wrappedValue))
        self._username = State(initialValue: _user.wrappedValue.username)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    VStack(spacing: 8) {
                        Divider()
                        
                        PhotosPicker(selection: $viewModel.selectedImage) {
                                VStack {
                                    if let image = viewModel.profileImage {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                            .foregroundColor(Color(.systemGray4))
                                    } else {
                                        CircularProfileImageView(user: user, size: .large)
                                    }
                                    Text("Edit profile picture")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding(.vertical, 8)
                        
                        Divider()
                    }
                    .padding(.bottom, 4)
                    
                    VStack {
                        EditProfileRowView(title: "Name", placeholder: "Enter your name..", inputSource: .userNameText, text: $viewModel.username, wordCount: $viewModel.usernameWordCount, limit: 30)
                        
                        Divider()

                        EditProfileRowView(title: "Bio", placeholder: "Enter your bio..",inputSource: .bioText, text: $viewModel.bio, wordCount: $viewModel.bioWordCount, limit: 50)
                    }
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.subheadline)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            Task {
                                editing = true
                                try await viewModel.updateUserData()
                                
                                dismiss()
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    }
                }
                .onReceive(viewModel.$user, perform: { user in
                    self.user = user
                })
                .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
                
                if editing {
                    Text("Loading")
                        .foregroundColor(.gray)
                        .padding(.top, 90)
                        .onDisappear{editing = false}
                    ProgressView()
                        .scaleEffect(1, anchor: .center)
                        .padding(.top)
                }
            }
        }

    }
}

struct EditProfileRowView: View {
    let title: String
    let placeholder: String
    var inputSource: InputSource
    @Binding var text: String
    @Binding var wordCount: Int // 新增绑定属性
    let limit: Int // 传入限制值

        var body: some View {
            HStack {
                Text(title)
                    .padding(.leading, 8)
                    .frame(width: 69, alignment: .leading)

                TextField(placeholder, text: $text)
                    .onChange(of: text) { newValue in
                        let result = TextProcessing.updateWordCountAndLimit(text: newValue, limit: limit, inputSource: inputSource)
                        text = result.newText
                        wordCount = result.wordCount
                    }
                    .padding(.top,8)

                Text("\(limit - wordCount) left")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Divider()
            }
            .font(.subheadline)
            .frame(height: 36)
        }
    }

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView(user: .constant(dev.user))
    }
}
