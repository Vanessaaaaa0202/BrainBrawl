//
//  LoginViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/29/23.
//

import Foundation
//
//class LoginViewModel: ObservableObject {
//    func login(withEmail email: String, password: String) async throws {
//        try await AuthService.shared.login(withEmail: email, password: password)
//    }
//}
@MainActor
class LoginViewModel: ObservableObject {
    @Published var hasLoginError: Bool = false
    func login(withEmail email: String, password: String) async{
           do {
               try await AuthService.shared.login(withEmail: email, password: password)
               hasLoginError = false  // Reset the error state on successful login
           } catch {
               hasLoginError = true  // Set the error state on login failure
           }
       }
}
