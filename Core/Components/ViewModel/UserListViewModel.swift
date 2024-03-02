//
//  UserListViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/21/23.
//

import Firebase

@MainActor
class UserListViewModel: ObservableObject {
    @Published var users = [User]()
    
    init() {
        Task { await fetchUsers() }
    }
    
    func fetchUsers() async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = FirestoreConstants.UserCollection.limit(to: 20)
                
//        if let last = lastDoc {
//            let next = query.start(afterDocument: last)
//            guard let snapshot = try? await next.getDocuments() else { return }
//            self.lastDoc = snapshot.documents.last
//            self.users.append(contentsOf: snapshot.documents.compactMap({ try? $0.data(as: User.self) }))
//        } else {
//            guard let snapshot = try? await query.getDocuments() else { return }
//            self.lastDoc = snapshot.documents.last
//            self.users = snapshot.documents.compactMap({ try? $0.data(as: User.self) }).filter({ $0.id != currentUid })
//        }
        
        guard let snapshot = try? await query.getDocuments() else { return }
        self.users = snapshot.documents.compactMap({ try? $0.data(as: User.self) }).filter({ $0.id != currentUid })
    }
}
