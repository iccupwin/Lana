import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var leagueVM = LeagueViewModel(sqliteService: SQLiteService.shared)
    @ObservedObject private var hearts = HeartsService.shared

    @State private var path = NavigationPath()
    @State private var bloomIsAlive = false

    private var todayXP: Int { viewModel.dailyXP.last ?? 0 }

    var body: some View {
        NavigationStack(path: $path) {
            LotusAppScreen {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        pageHeader
                        dailyBloomCard
                        continueJourneyCard
                        todaysPlanCard
                        weeklyLeagueCard
                        quickPracticeSection

                        if let title = viewModel.latestAchievementTitle,
                           let icon = viewModel.latestAchievementIcon {
                            achievementCard(title: title, icon: icon)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                appState.refreshAll()
                viewModel.refresh(appState: appState)
                leagueVM.load()
                startBloomAnimation()
            }
            .navigationDestination(for: String.self) { value in
                navigationTarget(value)
            }
        }
    }

    private var pageHeader: some View {
        HStack(spacing: 13) {
            ZStack {
                Circle()
                    .fill(LotusApp.softAurora)
                    .frame(width: 44, height: 44)
                Text(initials)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.cobalt)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(greetingLine)
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text("Level \(appState.levelInfo.level) · \(appState.levelInfo.name)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }

            Spacer()

            LotusIconBadge(icon: appState.levelInfo.icon, color: LotusApp.mint, size: 42)
        }
    }

    private var dailyBloomCard: some View {
        VStack(spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Your daily bloom")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text(todayXP == 0 ? "A small step opens the first petal" : "Your practice is taking shape")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
                Spacer()
                Text("\(appState.levelInfo.xpToNext) XP to next")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.cobalt)
            }

            Image("LotusBloom")
                .resizable()
                .scaledToFit()
                .frame(height: 174)
                .scaleEffect(bloomIsAlive ? 1 : 0.96)
                .offset(y: bloomIsAlive ? -2 : 3)
                .shadow(color: LotusApp.violet.opacity(0.14), radius: 22, y: 10)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 3.6).repeatForever(autoreverses: true),
                    value: bloomIsAlive
                )
                .accessibilityHidden(true)

            HStack(spacing: 8) {
                metricChip(icon: "flame.fill", value: "\(viewModel.currentStreak)", label: "Day streak", color: LotusApp.amber)
                metricChip(icon: "bolt.fill", value: "\(appState.totalXP)", label: "Total XP", color: LotusApp.cobalt)
                metricChip(icon: "heart.fill", value: "\(hearts.hearts)", label: "Lives", color: LotusApp.danger)
            }

            VStack(spacing: 7) {
                HStack {
                    Text("Daily goal")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                    Spacer()
                    Text("\(todayXP) / 50 XP")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.cobalt)
                }
                LotusProgressBar(progress: Double(todayXP) / 50.0)
            }

            LotusGradientButton(title: "Start today’s lesson", icon: "arrow.right") {
                HapticService.shared.impact(.medium)
                path.append("quiz")
            }
        }
        .padding(16)
        .lotusGlassCard(cornerRadius: 26, opacity: 0.87)
    }

    private func metricChip(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .contentTransition(.numericText())
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(LotusApp.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 15).fill(color.opacity(0.07)))
    }

    private var continueJourneyCard: some View {
        Button {
            HapticService.shared.impact(.medium)
            path.append("quiz")
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("CONTINUE JOURNEY")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.2)
                        .foregroundStyle(LotusApp.cobalt)
                    Text(viewModel.currentWorldName)
                        .font(.system(size: 21, weight: .regular, design: .serif))
                        .foregroundStyle(LotusApp.ink)
                    Text(viewModel.worldProgress)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
                Spacer()
                ZStack {
                    Circle().fill(LotusApp.softAurora).frame(width: 58, height: 58)
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(LotusApp.aurora)
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LotusApp.cobalt)
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .fill(Color.white.opacity(0.83))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 23, style: .continuous)
                            .fill(LotusApp.softAurora)
                            .frame(width: 120)
                            .blur(radius: 22)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 23, style: .continuous)
                            .stroke(Color.white, lineWidth: 1)
                    }
                    .shadow(color: LotusApp.ink.opacity(0.07), radius: 18, y: 8)
            }
        }
        .buttonStyle(PressScaleStyle())
    }

    private var todaysPlanCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            LotusSectionTitle(title: "Today’s plan", trailing: "\(appState.todayActivitiesCount)/3 complete")

            if viewModel.dailyQuests.isEmpty {
                planRow(icon: "book.fill", title: "Complete one lesson", subtitle: "Build today’s momentum", progress: 0) {
                    path.append("quiz")
                }
                Divider().overlay(LotusApp.ink.opacity(0.06))
                planRow(icon: "clock.fill", title: "Practice for five minutes", subtitle: "A short session is enough", progress: 0) {
                    path.append("grammar")
                }
            } else {
                ForEach(Array(viewModel.dailyQuests.prefix(2).enumerated()), id: \.element.id) { index, quest in
                    if index > 0 { Divider().overlay(LotusApp.ink.opacity(0.06)) }
                    planRow(icon: quest.icon, title: quest.title, subtitle: quest.description, progress: quest.fraction) {
                        switch quest.type {
                        case .saveWords, .reviewWords: path.append("saved")
                        default: path.append("quiz")
                        }
                    }
                }
            }
        }
        .padding(16)
        .lotusGlassCard()
    }

    private func planRow(
        icon: String,
        title: String,
        subtitle: String,
        progress: Double,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                LotusIconBadge(icon: icon, color: progress >= 1 ? LotusApp.mint : LotusApp.cobalt, size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: progress >= 1 ? "checkmark.circle.fill" : "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(progress >= 1 ? LotusApp.mint : LotusApp.subtle)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var weeklyLeagueCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack {
                Label("Weekly league", systemImage: "trophy.fill")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                Button("See all") { path.append("league") }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.cobalt)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(Array(leagueVM.players.prefix(6).enumerated()), id: \.element.id) { index, player in
                        leagueChip(rank: index + 1, player: player)
                    }
                }
            }
        }
        .padding(16)
        .lotusGlassCard()
    }

    private func leagueChip(rank: Int, player: LeaguePlayer) -> some View {
        HStack(spacing: 7) {
            Text("#\(rank)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(rank == 1 ? LotusApp.amber : LotusApp.muted)
            ZStack {
                Circle().fill(
                    player.isCurrentUser
                        ? AnyShapeStyle(LotusApp.softAurora)
                        : AnyShapeStyle(LotusApp.ink.opacity(0.05))
                )
                Text(player.isCurrentUser ? "Y" : String(player.name.prefix(1)))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(player.isCurrentUser ? LotusApp.cobalt : LotusApp.ink)
            }
            .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(player.isCurrentUser ? "You" : player.name)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                    .lineLimit(1)
                Text("\(player.weeklyXP) XP")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background {
            RoundedRectangle(cornerRadius: 13)
                .fill(Color.white.opacity(0.76))
                .overlay {
                    RoundedRectangle(cornerRadius: 13)
                        .stroke(player.isCurrentUser ? LotusApp.cobalt.opacity(0.5) : Color.white, lineWidth: 1)
                }
        }
    }

    private var quickPracticeSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            LotusSectionTitle(title: "Quick practice")
            HStack(spacing: 9) {
                quickButton(title: "Grammar", icon: "textformat.abc", color: LotusApp.cobalt, destination: "grammar")
                quickButton(title: "Listening", icon: "headphones", color: LotusApp.violet, destination: "listening")
                quickButton(title: "Stories", icon: "books.vertical.fill", color: LotusApp.amber, destination: "stories")
            }
        }
    }

    private func quickButton(title: String, icon: String, color: Color, destination: String) -> some View {
        Button { path.append(destination) } label: {
            VStack(spacing: 8) {
                LotusIconBadge(icon: icon, color: color, size: 40)
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .lotusGlassCard(cornerRadius: 17, opacity: 0.78, shadow: 0.04)
        }
        .buttonStyle(PressScaleStyle())
    }

    private func achievementCard(title: String, icon: String) -> some View {
        HStack(spacing: 12) {
            LotusIconBadge(icon: icon, color: LotusApp.amber, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text("Latest achievement")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(LotusApp.mint)
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 18)
    }

    private var initials: String {
        let parts = viewModel.userName.split(separator: " ")
        guard !parts.isEmpty else { return "U" }
        if parts.count > 1 {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        }
        return String(parts[0].prefix(2)).uppercased()
    }

    private var greetingLine: String {
        let name = viewModel.userName.split(separator: " ").first.map(String.init)
        return name.map { "\(greetingText), \($0)" } ?? "\(greetingText)!"
    }

    private var greetingText: String {
        switch Calendar.current.component(.hour, from: Date()) {
        case 6..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private func startBloomAnimation() {
        guard !reduceMotion else {
            bloomIsAlive = true
            return
        }
        bloomIsAlive = false
        DispatchQueue.main.async { bloomIsAlive = true }
    }

    @ViewBuilder
    private func navigationTarget(_ value: String) -> some View {
        switch value {
        case "quiz":
            QuizListView().environmentObject(appState)
        case "grammar":
            GrammarView(viewModel: GrammarViewModel(repository: appState.contentRepository))
        case "listening":
            ListeningView(viewModel: ListeningViewModel(repository: appState.contentRepository))
        case "movies":
            MoviesView(viewModel: MoviesViewModel(repository: appState.contentRepository))
        case "stories":
            StoriesView(repository: appState.contentRepository, sqliteService: appState.sqliteService)
                .environmentObject(appState)
        case "speed_review":
            SpeedReviewView(sqliteService: appState.sqliteService).environmentObject(appState)
        case "word":
            WordOfDayView(viewModel: WordOfDayViewModel(
                repository: appState.contentRepository,
                sqliteService: appState.sqliteService
            ))
        case "search":
            SearchView().environmentObject(appState)
        case "saved":
            SavedWordsView(viewModel: SavedWordsViewModel(sqliteService: appState.sqliteService))
                .environmentObject(appState)
        case "league":
            LeagueView(sqliteService: appState.sqliteService).environmentObject(appState)
        default:
            QuizListView().environmentObject(appState)
        }
    }
}
