//
//  Message.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import FirebaseFirestoreSwift
import Firebase

struct Message: Identifiable, Hashable, Decodable {
    let id: String
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    let text: String
    
    var user: User?
    
    var chatPartnerId: String { return fromId == Auth.auth().currentUser?.uid ? toId : fromId }
}
