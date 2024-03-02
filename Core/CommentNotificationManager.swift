//
//  CommentNotificationManager.swift
//  InstagramSwiftUITutorial
//
//  Created by sk_sunflower@163.com on 2023/12/13.
//

import Foundation

class CommentNotificationManager: ObservableObject {
    @Published var showCommentNotification: Bool = false
    @Published var commentType: CommentType = .blue // Default to blue or consider using an Optional

    enum CommentType {
        case red
        case blue
    }

    func triggerCommentNotification(withType type: CommentType) {
        self.commentType = type
        self.showCommentNotification = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showCommentNotification = false
        }
    }
}


