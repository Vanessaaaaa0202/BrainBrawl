//
//  ProfileViewModel.swift
//  InstagramSwiftUITutorial
//
//  Created by Stephen Dowless on 12/30/20.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        self.user = user
        loadUserData()
    }
    
    func loadUserData() {
        Task {
            async let stats = try await UserService.fetchUserStats(uid: user.id)
            self.user.stats = try await stats
            
            async let isFollowed = await checkIfUserIsFollowed()
            self.user.isFollowed = await isFollowed
        }
    }
    
    func refreshUserStats() {
        Task {
            do {
                let stats = try await UserService.fetchUserStats(uid: user.id)
                DispatchQueue.main.async {
                    self.user.stats = stats
                }
            } catch {
                print("Error fetching user stats: \(error)")
            }
        }
    }
}

// MARK: - Following

extension ProfileViewModel {
    func follow() {
        Task {
            try await UserService.follow(uid: user.id)
            user.isFollowed = true
            user.stats?.followers += 1
            NotificationService.uploadNotification(toUid: user.id, type: .follow)
        }
    }
    
    func unfollow() {
        Task {
            try await UserService.unfollow(uid: user.id)
            user.isFollowed = false
            user.stats?.followers -= 1
        }
    }
    
    func checkIfUserIsFollowed() async -> Bool {
        guard !user.isCurrentUser else { return false }
        return await UserService.checkIfUserIsFollowed(uid: user.id)
    }
}
