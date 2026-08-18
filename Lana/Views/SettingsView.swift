import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @EnvironmentObject private var appState: AppState

    private func hourLabel(_ hour: Int) -> String {
        let cal = Calendar.current
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = 0
        let date = cal.date(from: comps) ?? Date()
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: date)
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                    // MARK: Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PREFERENCES")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(DarkDS.muted)
                                .tracking(1.5)
                            Text("Settings")
                                .font(.system(size: 31, weight: .regular, design: .serif))
                                .foregroundStyle(LotusApp.ink)
                        }
                        Spacer()
                    }
                    .padding(.top, 16)

                    // MARK: Profile Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionTitle("Profile")
                            HStack(spacing: 12) {
                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 22))
                                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                                TextField("Your name", text: $viewModel.userName)
                                    .font(.system(size: 16))
                                    .foregroundStyle(LotusApp.ink)
                                    .tint(DarkDS.lime)
                                    .submitLabel(.done)
                            }
                            Divider().background(DarkDS.border)
                        }
                    }

                    // MARK: Notifications Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Notifications")

                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(red: 0.98, green: 0.55, blue: 0.20))
                                Text("Enable reminders")
                                    .font(.system(size: 15))
                                    .foregroundStyle(LotusApp.ink)
                                Spacer()
                                Toggle("", isOn: $viewModel.notificationsEnabled)
                                    .labelsHidden()
                                    .tint(DarkDS.lime)
                            }

                            if viewModel.notificationsEnabled {
                                Divider().background(DarkDS.border)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                                        Text("Reminder time")
                                            .font(.system(size: 14))
                                            .foregroundStyle(LotusApp.ink)
                                        Spacer()
                                        Text(hourLabel(viewModel.notificationHour))
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundStyle(DarkDS.muted)
                                    }

                                    Picker("Reminder time", selection: $viewModel.notificationHour) {
                                        ForEach(6...22, id: \.self) { hour in
                                            Text(hourLabel(hour)).tag(hour)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 120)
                                    .clipped()
                                    .colorScheme(.light)
                                }
                            }
                        }
                    }
                    .onChange(of: viewModel.notificationsEnabled) { _ in
                        viewModel.applyNotificationPreference()
                    }
                    .onChange(of: viewModel.notificationHour) { _ in
                        viewModel.applyNotificationPreference()
                    }

                    // MARK: Daily Goal Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Daily Goal")

                            HStack {
                                Image(systemName: "target")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                                Text("Activities per day")
                                    .font(.system(size: 15))
                                    .foregroundStyle(LotusApp.ink)
                                Spacer()
                                Text("\(viewModel.dailyGoalTarget)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(DarkDS.muted)
                            }

                            HStack(spacing: 12) {
                                ForEach([1, 3, 5], id: \.self) { target in
                                    let isSelected = viewModel.dailyGoalTarget == target
                                    Button {
                                        viewModel.dailyGoalTarget = target
                                    } label: {
                                        Text("\(target)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(isSelected ? .white : LotusApp.ink)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(isSelected ? DarkDS.lime : DarkDS.card2)
                                            )
                                    }
                                    .buttonStyle(PressScaleStyle())
                                }
                            }

                            HStack(spacing: 12) {
                                ForEach([1, 3, 5], id: \.self) { target in
                                    let labels = [1: "Easy", 3: "Regular", 5: "Intensive"]
                                    Text(labels[target] ?? "")
                                        .font(.system(size: 10))
                                        .foregroundStyle(DarkDS.muted)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }

                    // MARK: Appearance Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionTitle("Appearance")
                            HStack(spacing: 12) {
                                LotusIconBadge(icon: "sparkles", color: LotusApp.violet, size: 44)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Lotus Light")
                                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                                        .foregroundStyle(LotusApp.ink)
                                    Text("The Aurora palette stays consistent across every lesson.")
                                        .font(.system(size: 11, design: .rounded))
                                        .foregroundStyle(LotusApp.muted)
                                }
                            }
                        }
                    }

                    // MARK: About Section
                    sectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            sectionTitle("About")

                            HStack {
                                Image(systemName: "app.badge")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
                                Text("Version")
                                    .font(.system(size: 15))
                                    .foregroundStyle(LotusApp.ink)
                                Spacer()
                                Text("1.0.0")
                                    .font(.system(size: 14))
                                    .foregroundStyle(DarkDS.muted)
                            }

                            Divider().background(DarkDS.border)

                            HStack {
                                Image(systemName: "swift")
                                    .font(.system(size: 16))
                                    .foregroundStyle(Color(red: 0.98, green: 0.55, blue: 0.20))
                                Text("Built with SwiftUI")
                                    .font(.system(size: 15))
                                    .foregroundStyle(LotusApp.ink)
                                Spacer()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.preferredTheme = "light" }
        .onDisappear {
            appState.refreshAll()
        }
    }

    // MARK: Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(DarkDS.muted)
            .tracking(1.2)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .lotusGlassCard(cornerRadius: 21, opacity: 0.84, shadow: 0.05)
    }
}
