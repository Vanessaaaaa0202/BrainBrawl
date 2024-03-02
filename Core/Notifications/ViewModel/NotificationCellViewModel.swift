import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class NotificationCellViewModel: ObservableObject {
    @Published var notification: Notification
    @State private var isLoadingUser = false
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    
    
    private func fetchUserData(ownerUid: String) {
        guard !isLoadingUser else { return }
        isLoadingUser = true

        Task {
            if let fetchedUser = try? await UserService.fetchUser(withUid: ownerUid) {
                DispatchQueue.main.async { [self] in  // Removed 'weak' here
                    self.notification.post?.user = fetchedUser
                    self.isLoadingUser = false
                }
            }
        }
    }
    
    func follow() {
        Task {
            try await UserService.follow(uid: notification.uid)
            NotificationService.uploadNotification(toUid: self.notification.uid, type: .follow)
            self.notification.isFollowed = true
        }
    }
    
    func unfollow() {
        Task {
            try await UserService.unfollow(uid: notification.uid)
            self.notification.isFollowed = false
        }
    }
    
    // 修改 markNotificationsAsViewed 方法，接受特定的 notificationId
    func markNotificationAsViewed(notificationId: String) async {
        print("Marking notification as viewed...")
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotificationsRef = Firestore.firestore()
            .collection("notifications")
            .document(userId)
            .collection("user-notifications")

        do {
            // 直接更新特定通知的 'viewed' 字段为 true
            try await userNotificationsRef.document(notificationId).updateData(["viewed": true])
        } catch {
            print("Error updating notification: \(error)")
        }
    }

}
