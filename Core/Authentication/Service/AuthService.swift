//
//  AuthService.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/29/23.
//

import Foundation
import Firebase


class AuthService {
    @Published var user: User?
    @Published var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        Task { try await loadUserData() }
    }
    
    @MainActor
    func login(withEmail email: String, password: String) async throws {
        //MARK: cancel this part of error catching so error message can appear later
        //do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            self.user = try await UserService.fetchUser(withUid: result.user.uid)
        //} catch {
        //    print("DEBUG: Login failed \(error.localizedDescription)")
        //}
    }
    
    @MainActor
    func createUser(email: String, password: String, username: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            
            let data: [String: Any] = [
                "email": email,
                "username": username,
                "id": result.user.uid
            ]
            
            try await FirestoreConstants.UserCollection.document(result.user.uid).setData(data)
            self.user = try await UserService.fetchUser(withUid: result.user.uid)
        } catch {
            print("DEBUG: Failed to create user with error: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    func loadUserData() async throws {
        userSession = Auth.auth().currentUser
        
        if let session = userSession {
            self.user = try await UserService.fetchUser(withUid: session.uid)
        }
    }
    
    func sendResetPasswordLink(toEmail email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signout() {
        self.userSession = nil
        self.user = nil
        try? Auth.auth().signOut()
    }
}
