import SwiftUI
import Firebase
import FirebaseFirestoreSwift

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications = [Notification]()
    private var isLoading = false
    @Published var shouldShowNotificationBadge = false // 控制通知徽章显示
    @Published var unreadCount = 0
    private var lastDocumentSnapshot: DocumentSnapshot?
    private var currentPage = 0
    private var isLastPage = false
    private var listenerRegistration: ListenerRegistration?
    

    init() {
        //load notification
        listenToUserNotifications()
    }
    
    func listenToUserNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        isLoading = true
        currentPage = 0 // 重置页码
        // 只加载第一页数据
        loadMoreNotifications()

        listenerRegistration = Firestore.firestore()
            .collection("notifications")
            .document(userId)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)
            .limit(to: 10)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    self.notifications = snapshot.documents.compactMap { document in
                        try? document.data(as: Notification.self)
                    }
                    self.lastDocumentSnapshot = snapshot.documents.last
                    self.updateNotificationsMetadata()
                    self.calculateUnreadNotifications()
                }
                self.isLoading = false
            }
    }

    func loadMoreNotifications() {
        guard let userId = Auth.auth().currentUser?.uid, !isLoading, !isLastPage else { return }

        isLoading = true

        var query = Firestore.firestore()
            .collection("notifications")
            .document(userId)
            .collection("user-notifications")
            .order(by: "timestamp", descending: true)
            .limit(to: 10)

        if let lastSnapshot = lastDocumentSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            defer { self.isLoading = false }

            guard let snapshot = querySnapshot, !snapshot.documents.isEmpty else {
                self.isLastPage = true
                return
            }

            let moreNotifications = snapshot.documents.compactMap { document in
                try? document.data(as: Notification.self)
            }

            if !moreNotifications.isEmpty {
                self.notifications.append(contentsOf: moreNotifications)
                self.lastDocumentSnapshot = snapshot.documents.last
            } else {
                self.isLastPage = true // No more notifications to load
            }

            self.updateNotificationsMetadata()
            self.calculateUnreadNotifications()
            self.currentPage += 1
        }
    }




    private func updateNotificationsMetadata() {
        Task {
            await withThrowingTaskGroup(of: Void.self, body: { group in
                for notification in notifications {
                    group.addTask {
                        do {
                            try await self.updateNotificationMetadata(notification: notification)
                        } catch {
                            print("Error updating notification metadata: \(error.localizedDescription)")
                        }
                    }
                }
            })
            
            DispatchQueue.main.async { // 确保在主线程更新UI
                self.isLoading = false // 所有数据加载完成后设置
            }
        }
    }

    


    private func updateNotificationMetadata(notification: Notification) async throws {

        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        async let notificationUser = try await UserService.fetchUser(withUid: notification.uid)
        self.notifications[indexOfNotification].user = try await notificationUser

        if notification.type == .follow {
            async let isFollowed = await UserService.checkIfUserIsFollowed(uid: notification.uid)
            self.notifications[indexOfNotification].isFollowed = await isFollowed
        }

        if let postId = notification.postId {
            async let postSnapshot = await FirestoreConstants.PostsCollection.document(postId).getDocument()
            var postreal = try await postSnapshot.data(as: Post.self)
            let fetchedUser = try await UserService.fetchUser(withUid: postreal.ownerUid)
            postreal.user = fetchedUser
            self.notifications[indexOfNotification].post = try? await postreal
        }
        
        if notification.type == .likeReply || notification.type == .replyToReply || notification.type == .replyToComment {
            // 如果通知与回复相关
            if let replyId = notification.replyId, let postId = notification.postId, let commentId = notification.commentId {
                async let replySnapshot = await FirestoreConstants
                    .RepliesCollection(forPostId: postId, commentId: commentId)
                    .document(replyId)
                    .getDocument()

                self.notifications[indexOfNotification].reply = try? await replySnapshot.data(as: Reply.self)
            }
        }
    
    }
    
    
    // 修改 markNotificationsAsViewed 方法，接受特定的 notificationId
    func calculateUnreadNotifications() {
        unreadCount = notifications.filter { !($0.viewed ?? true) }.count
        print(unreadCount)
    }

    
    func markNotificationsAsViewed() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userNotificationsRef = Firestore.firestore()
            .collection("notifications")
            .document(userId)
            .collection("user-notifications")

        do {
            let querySnapshot = try await userNotificationsRef.whereField("viewed", isEqualTo: false).getDocuments()
            let batch = Firestore.firestore().batch()

            querySnapshot.documents.forEach { document in
                let docRef = userNotificationsRef.document(document.documentID)
                batch.updateData(["viewed": true], forDocument: docRef)
            }

            // Commit the batch
            try await batch.commit()
            // 由于我们是在批量更新后执行此操作，所以我们可以在这里直接更新UI
            DispatchQueue.main.async {
                self.calculateUnreadNotifications()
                self.shouldShowNotificationBadge = false
                self.isLoading = false // 可能需要根据实际情况调整此处的isLoading状态更新位置
            }
        } catch {
            print("Error marking notifications as viewed: \(error)")
            self.isLoading = false
        }
    }



    deinit {
            listenerRegistration?.remove()
        }
    
 
}
