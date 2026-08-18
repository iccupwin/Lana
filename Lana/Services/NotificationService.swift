import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    // Local notifications are used; APNs can be wired later for remote push.

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func scheduleDailyWordNotification(at hour: Int = 9) {
        let content = UNMutableNotificationContent()
        content.title = "Word of the Day"
        content.body = "Open the app to learn today's word."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "word_of_day", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleQuizReminder(at hour: Int = 18) {
        let content = UNMutableNotificationContent()
        content.title = "Quiz Reminder"
        content.body = "Take a quick quiz to keep your streak going."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "quiz_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleStreakReminder(at hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak! 🔥"
        content.body = "Complete one activity today."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "streak_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func scheduleDailyGoalReminder(at hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Almost there!"
        content.body = "You're close to your daily goal! Keep going 💪"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_goal_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func rescheduleAll(hour: Int, enabled: Bool) {
        cancelAll()
        guard enabled else { return }
        scheduleDailyWordNotification(at: hour)
        scheduleStreakReminder(at: hour)
        scheduleDailyGoalReminder(at: hour)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
