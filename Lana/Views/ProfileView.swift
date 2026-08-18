import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showSettings = false
    @State private var emblemIsAlive = false

    var body: some View {
        LotusAppScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    LotusPageHeader(
                        title: "Profile",
                        subtitle: "Your learning journey",
                        actionIcon: "gearshape.fill",
                        action: {
                            HapticService.shared.selection()
                            showSettings = true
                        }
                    )
                    identityCard
                    statsCard
                    infoCard
                    accountSettingsCard
                    learningLinksCard
                    servicesCard
                    logOutButton
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.refresh()
            appState.refreshAll()
            startEmblemAnimation()
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(viewModel: SettingsViewModel())
                    .environmentObject(appState)
            }
        }
    }

    private var identityCard: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(LotusApp.softAurora)
                    .frame(width: 82, height: 82)
                Image("LotusBloom")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 76, height: 76)
                    .scaleEffect(emblemIsAlive ? 1 : 0.94)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 3.6).repeatForever(autoreverses: true),
                        value: emblemIsAlive
                    )
            }
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 7) {
                Text(viewModel.name.isEmpty ? "Your Name" : viewModel.name)
                    .font(.system(size: 22, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)

                HStack(spacing: 5) {
                    Image(systemName: appState.levelInfo.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(LotusApp.mint)
                    Text(appState.levelInfo.name)
                    Text("·")
                    Text("\(appState.totalXP) XP")
                        .foregroundStyle(LotusApp.cobalt)
                }
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(LotusApp.muted)

                Text("\(appState.cefrLevel.rawValue) · \(appState.cefrLevel.description)")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.cobalt)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(LotusApp.cobalt.opacity(0.08)))
            }
            Spacer(minLength: 0)
        }
        .padding(17)
        .lotusGlassCard(cornerRadius: 24, opacity: 0.87)
    }

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            LotusSectionTitle(title: "My stats")

            HStack(spacing: 8) {
                statItem("graduationcap.fill", "Lv.\(appState.levelInfo.level)", "Level", LotusApp.mint)
                statItem("flame.fill", "\(viewModel.stats.currentStreak)d", "Streak", LotusApp.amber)
                statItem("checkmark.seal.fill", "\(viewModel.stats.quizzesTaken)", "Quizzes", LotusApp.cobalt)
                statItem("bookmark.fill", "\(viewModel.stats.learnedWords)", "Words", LotusApp.violet)
            }

            VStack(spacing: 7) {
                HStack {
                    Text("Progress to next level")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                    Spacer()
                    Text("\(appState.totalXP) XP")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.cobalt)
                }
                LotusProgressBar(progress: appState.levelInfo.progress, height: 7)
            }
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 22)
    }

    private func statItem(_ icon: String, _ value: String, _ label: String, _ color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 8, design: .rounded))
                .foregroundStyle(LotusApp.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 15).fill(color.opacity(0.07)))
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            LotusSectionTitle(title: "Personal info")
            profileField(label: "Name", placeholder: "Enter your name", text: $viewModel.name)
            profileField(label: "About me", placeholder: "Tell us about your learning goals…", text: $viewModel.bio)
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 22)
    }

    private func profileField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(LotusApp.muted)
            TextField(placeholder, text: text)
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .tint(LotusApp.cobalt)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(RoundedRectangle(cornerRadius: 14).fill(LotusApp.ink.opacity(0.035)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.86), lineWidth: 1))
        }
    }

    private var accountSettingsCard: some View {
        settingsSection("Account settings") {
            settingsRow(icon: "bell.fill", color: LotusApp.amber, title: "Notifications") {
                SettingsView(viewModel: SettingsViewModel()).environmentObject(appState)
            }
            divider
            settingsRow(icon: "crown.fill", color: LotusApp.violet, title: "My plan") {
                TrophyRoomView().environmentObject(appState)
            }
            divider
            settingsRow(icon: "globe", color: LotusApp.cobalt, title: "Language") {
                SettingsView(viewModel: SettingsViewModel()).environmentObject(appState)
            }
            divider
            settingsRow(icon: "lock.fill", color: LotusApp.mint, title: "Password & security") {
                SettingsView(viewModel: SettingsViewModel()).environmentObject(appState)
            }
        }
    }

    private var learningLinksCard: some View {
        settingsSection("Your journey") {
            settingsRow(icon: "trophy.fill", color: LotusApp.amber, title: "Trophy room", badge: "\(appState.unlockedAchievementIds.count)/\(AchievementDef.all.count)") {
                TrophyRoomView().environmentObject(appState)
            }
            divider
            settingsRow(icon: "doc.badge.plus", color: LotusApp.cobalt, title: "Certificate") {
                CertificateView(userName: viewModel.name).environmentObject(appState)
            }
            divider
            settingsRow(icon: "square.and.arrow.up", color: LotusApp.violet, title: "Share progress") {
                ShareProgressView().environmentObject(appState)
            }
        }
    }

    private var servicesCard: some View {
        settingsSection("Services") {
            settingsRow(icon: "hand.raised.fill", color: LotusApp.muted, title: "Privacy policy") { EmptyView() }
            divider
            settingsRow(icon: "doc.text.fill", color: LotusApp.muted, title: "Terms & conditions") { EmptyView() }
            divider
            settingsRow(icon: "info.circle.fill", color: LotusApp.muted, title: "About this app") { EmptyView() }
        }
    }

    private func settingsSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            LotusSectionTitle(title: title)
            VStack(spacing: 0) {
                content()
            }
            .lotusGlassCard(cornerRadius: 20)
        }
    }

    private var divider: some View {
        Divider()
            .overlay(LotusApp.ink.opacity(0.055))
            .padding(.leading, 58)
    }

    private func settingsRow<Destination: View>(
        icon: String,
        color: Color,
        title: String,
        badge: String? = nil,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink { destination() } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color.opacity(0.09))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(color)
                }
                Text(title)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                if let badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(LotusApp.ink.opacity(0.04)))
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(LotusApp.subtle)
            }
            .padding(.horizontal, 13)
            .frame(minHeight: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressScaleStyle())
    }

    private var logOutButton: some View {
        Button {
            HapticService.shared.impact(.medium)
        } label: {
            Label("Log out", systemImage: "arrow.backward.circle.fill")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.danger)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background {
                    RoundedRectangle(cornerRadius: 17)
                        .fill(LotusApp.danger.opacity(0.07))
                        .overlay(RoundedRectangle(cornerRadius: 17).stroke(LotusApp.danger.opacity(0.16), lineWidth: 1))
                }
        }
        .buttonStyle(PressScaleStyle())
    }

    private func startEmblemAnimation() {
        guard !reduceMotion else {
            emblemIsAlive = true
            return
        }
        emblemIsAlive = false
        DispatchQueue.main.async { emblemIsAlive = true }
    }
}
