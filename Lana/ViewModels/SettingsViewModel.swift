import Foundation
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("notificationHour") var notificationHour: Int = 9
    @AppStorage("dailyGoalTarget") var dailyGoalTarget: Int = 3
    @AppStorage("userName") var userName: String = ""
    @AppStorage("preferredTheme") var preferredTheme: String = "system"

    func applyNotificationPreference() {
        NotificationService.shared.rescheduleAll(hour: notificationHour, enabled: notificationsEnabled)
    }

    var colorScheme: ColorScheme? {
        switch preferredTheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil
        }
    }
}
