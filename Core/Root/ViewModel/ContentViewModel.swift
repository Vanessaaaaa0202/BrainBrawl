//
//  ContentViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephan Dowless on 4/29/23.
//

import Foundation
import Firebase 
import Combine

class ContentViewModel: ObservableObject {
    
    private let service = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        configureSubscribers()
    }
    
    func configureSubscribers() {
        service.$user
            .sink { [weak self] user in
                self?.currentUser = user
            }.store(in: &cancellables)
        
        service.$userSession
            .sink { [weak self] session in
                self?.userSession = session
            }.store(in: &cancellables)
    }
}
