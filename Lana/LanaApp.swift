import SwiftUI

@main
struct LanaApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    let enabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
                    if enabled {
                        let storedHour = UserDefaults.standard.integer(forKey: "notificationHour")
                        let hour = storedHour == 0 ? 9 : storedHour
                        NotificationService.shared.rescheduleAll(hour: hour, enabled: true)
                    }
                }
        }
    }
}
