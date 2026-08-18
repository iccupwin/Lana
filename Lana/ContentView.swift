import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        Group {
            if hasOnboarded {
                RootTabView()
                    .environmentObject(appState)
            } else {
                OnboardingView(viewModel: OnboardingViewModel())
            }
        }
        .preferredColorScheme(.light)
        .symbolRenderingMode(.monochrome)
        .onAppear {
            settingsViewModel.applyNotificationPreference()
        }
    }

}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
