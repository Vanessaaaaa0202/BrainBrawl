//
//  File.swift
//  InstagramSwiftUITutorial
//
//  Created by sk_sunflower@163.com on 2023/10/23.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct MainComment: Identifiable, Hashable, Codable {
    @DocumentID var id: String?
    let userId: String  // User who made the comment
    let postId: String  // Post on which the comment was made
    let commentText: String
    let timestamp: Timestamp
}
