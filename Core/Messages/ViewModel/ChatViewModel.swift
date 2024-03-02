//
//  ChatViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 1/9/21.
//

import SwiftUI
import Firebase

class ChatViewModel: ObservableObject {
    let user: User
    @Published var messages = [Message]()
    
    init(user: User) {
        self.user = user
        fetchMessages()
    }
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let query = FirestoreConstants.MessagesCollection
            .document(currentUid)
            .collection(user.id)
            .order(by: "timestamp", descending: false)
        
        query.addSnapshotListener { snapshot, error in
            guard let changes = snapshot?.documentChanges.filter({ $0.type == .added }) else { return }
            var newMessages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            for i in 0 ..< newMessages.count {
                let chatPartnerId = newMessages[i].chatPartnerId
                
                if chatPartnerId != currentUid {
                    newMessages[i].user = self.user
                }
            }
            
            self.messages.append(contentsOf: newMessages)
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let uid = user.id
        
        let currentUserRef = FirestoreConstants.MessagesCollection.document(currentUid).collection(uid).document()
        let receivingUserRef = FirestoreConstants.MessagesCollection.document(uid).collection(currentUid)
        let receivingRecentRef = FirestoreConstants.MessagesCollection.document(uid).collection("recent-messages")
        let currentRecentRef =  FirestoreConstants.MessagesCollection.document(currentUid).collection("recent-messages")
        
        let messageID = currentUserRef.documentID
        
        let data: [String: Any] = ["text": messageText,
                                   "id": messageID,
                                   "fromId": currentUid,
                                   "toId": uid,
                                   "timestamp": Timestamp(date: Date())]
        
        let recipientData: [String: Any] = ["text": messageText,
                                            "id": messageID,
                                            "fromId": currentUid,
                                            "toId": uid,
                                            "timestamp": Timestamp(date: Date())]
        
        currentUserRef.setData(data)
        currentRecentRef.document(uid).setData(data)

        receivingUserRef.document(messageID).setData(recipientData)
        receivingRecentRef.document(currentUid).setData(recipientData)
    }
}
