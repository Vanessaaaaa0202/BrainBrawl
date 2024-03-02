//
//  UploadPostViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/31/20.
//

import SwiftUI
import Firebase
import PhotosUI
import FirebaseFirestoreSwift
import FirebaseFirestore

extension UploadPostViewModel {
    func processText(_ text: String, limit: Int, inputSource: InputSource) -> (newText: String, wordCount: Int) {
        let wordsCount_vibe = TextProcessing.updateWordCountAndLimit(text: text, limit: limit, inputSource: inputSource)
        print(wordsCount_vibe)
        return wordsCount_vibe//TextProcessing.updateWordCountAndLimit(text: text, limit: limit, inputSource: inputSource)
    }
}


struct TextProcessing {

    
    static func updateWordCountAndLimit(text: String, limit: Int, inputSource: InputSource) -> (newText: String, wordCount: Int) {
        var newText = ""
        var wordCount = 0

        for char in text {
            // 不再区分输入源，直接按照字符计数
            if wordCount < limit {
                newText += String(char)
                wordCount += 1 // 每个字符都算作一个单独的词
            } else {
                break // 达到限制时停止添加字符
            }
        }

        return (newText, wordCount)
    }
    
        
}


@MainActor
class UploadPostViewModel: ObservableObject {
    @Published var didUploadPost = false
    //@Published var postTitle: String = ""
    @Published var error: Error?
    @Published var profileImage: Image?
    @Published var currentWordCount: Int = 0
    @Published var selectedImage: PhotosPickerItem? {
        didSet { Task { await loadImage(fromItem: selectedImage) } }
    }

    var inputSource: InputSource = .uploadPostTitle // Example, adjust as needed
        
    private var uiImage: UIImage?
    
    func determineLimitBasedOnInputSource(for inputSource: InputSource) -> Int {
        switch inputSource {
        case .uploadMedia:
            return 3000
        case .uploadPostTitle:
            return 30 // Limit to 30 words
        case .userNameText:
            return 15 // Limit to 15 characters
        case .bioText:
            return 50 // Limit to 50 characters
        default:
            return 1000
        }
    }
    
    @Published var postTitle: String = "" {
        didSet {
            let result = TextProcessing.updateWordCountAndLimit(text: postTitle, limit: determineLimitBasedOnInputSource(for: inputSource), inputSource: inputSource)

            DispatchQueue.main.async {
                self.postTitle = result.newText
                self.currentWordCount = result.wordCount
            }
        }
    }
    

    
    
    func uploadPost(title: String, caption: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let image = uiImage else { return }
        
        do {
            guard let imageUrl = try await ImageUploader.uploadImage(image: image, type: .post) else { return }
            let post = Post(
                ownerUid: uid,
                title: title,  // 此处正确使用传入的 title
                caption: caption,
                likes: 0,
                imageUrl: imageUrl,
                timestamp: Timestamp()
            )
            
            try await PostService.uploadPost(post)
            self.didUploadPost = true
        } catch {
            print("DEBUG: Failed to upload image with error \(error.localizedDescription)")
            self.error = error
        }
    }

    
    func loadImage(fromItem item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        guard let uiImage = UIImage(data: data) else { return }
        self.uiImage = uiImage
        self.profileImage = Image(uiImage: uiImage)
    }

}
