//
//  EditProfileViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI
import PhotosUI
import FirebaseFirestoreSwift
import Firebase

@MainActor
class EditProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var uploadComplete = false
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }
    @Published var profileImage: Image?
    private var uiImage: UIImage?
//    @Published var newUsername: String = ""
    
//    var fullname = ""
    @Published var username = "" {
        didSet {
            print("Username is about to change to: \(updateUserName())")
        }
    }
    @Published var bio: String = "" {
            didSet {
                updateBio()
            }
        }
    @Published var usernameWordCount: Int = 0
    @Published var bioWordCount: Int = 0
                
    init(user: User) {
        self.user = user
        self.username = user.username
        self.bio = user.bio ?? ""
    }
    
    @MainActor
    
    // 在 EditProfileViewModel 中
    func updateUserName() {
        let result = TextProcessing.updateWordCountAndLimit(text: username, limit: 30, inputSource: .userNameText)
        DispatchQueue.main.async {
            self.username = result.newText
            self.usernameWordCount = result.wordCount
        }
    }

    func updateBio() {
        let result = TextProcessing.updateWordCountAndLimit(text: bio, limit: 50, inputSource: .bioText)
        DispatchQueue.main.async {
            self.bio = result.newText
            self.bioWordCount = result.wordCount
        }
    }

    
    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)

    }
    
    func updateProfileImage(_ uiImage: UIImage) async throws {
        let imageUrl = try? await ImageUploader.uploadImage(image: uiImage, type: .profile)
        self.user.profileImageUrl = imageUrl
    }
    
    func updateUserData() async throws {
        var data: [String: String] = [:]

        if let uiImage = uiImage {
            try? await updateProfileImage(uiImage)
            data["profileImageUrl"] = user.profileImageUrl
        }
        
        // 检查新的用户名是否与当前的用户名不同
        if !username.isEmpty, user.username != username {
            // 更新Firebase数据库
            data["username"] = username
            // 同时更新本地的user对象
            user.username = username
        }
        
        if !bio.isEmpty, user.bio ?? "" != bio {
            user.bio = bio
            data["bio"] = bio
        }
        try await FirestoreConstants.UserCollection.document(user.id).updateData(data)
    }
}
