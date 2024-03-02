//
//  MessageViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import Firebase

struct MessageViewModel {
    let message: Message
    
    var currentUid: String { return Auth.auth().currentUser?.uid ?? "" }
    
    var isFromCurrentUser: Bool { return message.fromId == currentUid }
}
