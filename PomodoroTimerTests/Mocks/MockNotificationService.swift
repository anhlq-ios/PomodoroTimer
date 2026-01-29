import Foundation
@testable import PomodoroTimer

class MockNotificationService: NotificationServiceProtocol {
    var authorizationGranted = false
    var requestAuthorizationCalled = false
    var scheduledNotifications: [(title: String, body: String)] = []
    var cancelCalled = false

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        requestAuthorizationCalled = true
        completion(authorizationGranted)
    }

    func checkAuthorizationStatus(completion: @escaping (Bool) -> Void) {
        completion(authorizationGranted)
    }

    func scheduleNotification(title: String, body: String) {
        scheduledNotifications.append((title: title, body: body))
    }

    func cancelPendingNotifications() {
        cancelCalled = true
    }
}
