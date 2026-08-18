import SwiftUI

struct ShareProgressView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @AppStorage("userName") private var userName: String = ""
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    private var stats: ProgressStats { appState.sqliteService.fetchProgress() }

    var body: some View {
        DarkScreen {
            VStack(spacing: 24) {
                header
                statsCard
                    .padding(.horizontal, 20)
                shareButton
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(items: [img])
            }
        }
    }

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            Text("Share Progress")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    @ViewBuilder
    private var statsCard: some View {
        let s = stats
        VStack(spacing: 20) {
            // Top: app branding
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Lana")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(LotusApp.ink)
                    Text("English Learning")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
                Spacer()
                Image(systemName: appState.levelInfo.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            }

            Rectangle()
                .fill(DarkDS.muted.opacity(0.15))
                .frame(height: 1)

            // User name + level
            VStack(spacing: 6) {
                Text(userName.isEmpty ? "English Learner" : userName)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text(appState.levelInfo.name)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }

            // Stats grid 2x2
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                statCell(icon: "sparkles",            value: "\(appState.totalXP)",  label: "Total XP",    color: Color(red: 0.98, green: 0.79, blue: 0.20))
                statCell(icon: "flame.fill",          value: "\(s.currentStreak)d",  label: "Streak",      color: Color(red: 0.98, green: 0.55, blue: 0.20))
                statCell(icon: "checkmark.seal.fill", value: "\(s.quizzesTaken)",    label: "Quizzes",     color: Color(red: 0.20, green: 0.78, blue: 0.43))
                statCell(icon: "bookmark.fill",       value: "\(s.learnedWords)",    label: "Words Saved", color: Color(red: 0.22, green: 0.44, blue: 0.98))
            }

            // CEFR badge
            let cefr = appState.cefrLevel
            HStack(spacing: 8) {
                Text(cefr.rawValue)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                Text("·")
                    .foregroundStyle(DarkDS.muted)
                Text(cefr.description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
            }
            .foregroundStyle(LotusApp.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color(hex: cefr.color).opacity(0.5)))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(DarkDS.card)
        )
    }

    private func statCell(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(LotusApp.ink.opacity(0.6))
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.3)))
    }

    private var shareButton: some View {
        Button { renderAndShare() } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share My Progress")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
        }
        .buttonStyle(PressScaleStyle())
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content:
            statsCard
                .frame(width: 340)
                .environment(\.colorScheme, .light)
        )
        renderer.scale = 3.0
        if let img = renderer.uiImage {
            shareImage = img
            showShareSheet = true
        }
    }
}
