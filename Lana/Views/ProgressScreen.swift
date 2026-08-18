import SwiftUI

struct ProgressScreen: View {
    @ObservedObject var viewModel: ProgressViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("weeklyXPGoal") private var weeklyGoal = 300
    @State private var animateProgress = false
    @State private var dailyXP: [Int] = Array(repeating: 0, count: 7)
    @State private var freezeCount = 0

    private var accuracy: Int {
        guard viewModel.stats.quizzesTaken > 0 else { return 0 }
        let total = viewModel.stats.quizzesTaken * 5
        return min(100, Int(Double(viewModel.stats.correctAnswers) / Double(total) * 100))
    }

    private var hasActivityToday: Bool {
        viewModel.activityDays.contains(Int(Date().timeIntervalSince1970 / 86_400))
    }

    var body: some View {
        LotusAppScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    LotusPageHeader(
                        eyebrow: "Your journey",
                        title: "Progress",
                        actionIcon: "chart.bar.fill",
                        action: { HapticService.shared.selection() }
                    )
                    growthCard
                    streakCard
                    freezeCard
                    weeklyChallengeCard
                    if !hasActivityToday { streakProtectionCard }
                    weekCard
                    xpChartCard
                    statsGrid
                    achievementsCard
                    motivationCard
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
            dailyXP = appState.sqliteService.fetchDailyXP()
            freezeCount = viewModel.sqliteService.fetchStreakFreezeCount()

            if reduceMotion {
                animateProgress = true
            } else {
                animateProgress = false
                withAnimation(.spring(response: 0.85, dampingFraction: 0.78).delay(0.12)) {
                    animateProgress = true
                }
            }
        }
    }

    private var growthCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(viewModel.levelInfo.name)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text("Level \(viewModel.levelInfo.level) · \(appState.cefrLevel.rawValue) \(appState.cefrLevel.description)")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.totalXP) XP")
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                        .contentTransition(.numericText())
                    Text(viewModel.levelInfo.xpToNext > 0 ? "\(viewModel.levelInfo.xpToNext) to next level" : "Highest level")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
            }

            LotusAssetSurface(name: "LotusProgressGrowth", height: 146, cornerRadius: 20)
                .scaleEffect(animateProgress ? 1 : 0.97)
                .opacity(animateProgress ? 1 : 0.45)
                .animation(.easeOut(duration: 0.7), value: animateProgress)
                .accessibilityHidden(true)

            LotusProgressBar(progress: animateProgress ? viewModel.levelInfo.progress : 0, height: 8)

            HStack {
                Text("\(viewModel.levelInfo.minXP) XP")
                Spacer()
                Text("Next bloom")
                    .fontWeight(.semibold)
                    .foregroundStyle(LotusApp.cobalt)
                Spacer()
                Text("\(viewModel.levelInfo.maxXP) XP")
            }
            .font(.system(size: 9, design: .rounded))
            .foregroundStyle(LotusApp.muted)
        }
        .padding(16)
        .lotusGlassCard(cornerRadius: 25, opacity: 0.87)
    }

    private var streakCard: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Label("Current streak", systemImage: "flame.fill")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                Text("\(viewModel.stats.currentStreak) \(viewModel.stats.currentStreak == 1 ? "day" : "days")")
                    .font(.system(size: 34, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                    .contentTransition(.numericText())
                Text(streakMessage)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
            Spacer()
            ZStack {
                Circle().fill(streakColor.opacity(0.09)).frame(width: 68, height: 68)
                Image(systemName: streakIcon)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(streakColor)
                    .symbolEffect(.pulse, value: viewModel.stats.currentStreak)
            }
        }
        .padding(17)
        .lotusGlassCard(cornerRadius: 22)
    }

    private var freezeCard: some View {
        HStack(spacing: 12) {
            LotusIconBadge(icon: "snowflake", color: LotusApp.cobalt, size: 44)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("Streak Freeze")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "snowflake")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(index < freezeCount ? LotusApp.cobalt : LotusApp.subtle.opacity(0.44))
                    }
                }
                Text(freezeCount > 0 ? "\(freezeCount) available" : "Earn 100 XP to receive one")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
            Spacer()
            if freezeCount > 0 {
                Button("Use") {
                    viewModel.sqliteService.useStreakFreeze()
                    freezeCount = viewModel.sqliteService.fetchStreakFreezeCount()
                    viewModel.refresh()
                    HapticService.shared.notify(.success)
                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.cobalt)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(LotusApp.cobalt.opacity(0.08)))
                .buttonStyle(PressScaleStyle())
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }

    private var weeklyChallengeCard: some View {
        let progress = weeklyGoal > 0 ? Double(appState.weeklyXP) / Double(weeklyGoal) : 0

        return VStack(alignment: .leading, spacing: 12) {
            LotusSectionTitle(title: "Weekly challenge", trailing: "\(max(0, weeklyGoal - appState.weeklyXP)) XP to go")

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(appState.weeklyXP)")
                    .font(.system(size: 29, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                    .contentTransition(.numericText())
                Text("/ \(weeklyGoal) XP")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                Spacer()
            }

            LotusProgressBar(progress: progress, height: 9)

            HStack(spacing: 7) {
                goalChip(150, "Easy", "leaf.fill")
                goalChip(300, "Medium", "flame.fill")
                goalChip(500, "Hard", "bolt.fill")
                goalChip(750, "Expert", "trophy.fill")
            }
        }
        .padding(16)
        .lotusGlassCard(cornerRadius: 22)
    }

    private func goalChip(_ xp: Int, _ title: String, _ icon: String) -> some View {
        let selected = weeklyGoal == xp

        return Button { weeklyGoal = xp } label: {
            HStack(spacing: 3) {
                Image(systemName: icon).font(.system(size: 8, weight: .semibold))
                Text(title)
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .lineLimit(1)
            }
            .foregroundStyle(selected ? .white : LotusApp.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Capsule().fill(selected ? AnyShapeStyle(LotusApp.aurora) : AnyShapeStyle(LotusApp.ink.opacity(0.045))))
        }
        .buttonStyle(PressScaleStyle())
    }

    private var streakProtectionCard: some View {
        HStack(spacing: 11) {
            LotusIconBadge(icon: "exclamationmark.shield.fill", color: LotusApp.amber, size: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text("Protect your streak")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text("Complete any activity today to keep your rhythm.")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18)
                .fill(LotusApp.amber.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(LotusApp.amber.opacity(0.18), lineWidth: 1))
        }
    }

    private var weekCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            LotusSectionTitle(title: "This week")
            HStack(spacing: 0) {
                ForEach(0..<7) { offset in
                    let dayKey = Int(Date().timeIntervalSince1970 / 86_400) - (6 - offset)
                    let active = viewModel.activityDays.contains(dayKey)
                    let today = offset == 6

                    VStack(spacing: 6) {
                        Text(weekdayLabel(offset))
                            .font(.system(size: 8, weight: .semibold, design: .rounded))
                            .foregroundStyle(LotusApp.muted)
                        ZStack {
                            Circle()
                                .fill(active ? AnyShapeStyle(LotusApp.aurora) : AnyShapeStyle(LotusApp.ink.opacity(0.05)))
                                .frame(width: 31, height: 31)
                            if today {
                                Circle().stroke(LotusApp.cobalt.opacity(0.45), lineWidth: 1.2).frame(width: 35, height: 35)
                            }
                            Image(systemName: active ? "checkmark" : "leaf")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(active ? .white : LotusApp.subtle)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 20)
    }

    private var xpChartCard: some View {
        let maxXP = max(1, dailyXP.max() ?? 0)

        return VStack(alignment: .leading, spacing: 13) {
            LotusSectionTitle(title: "XP rhythm", trailing: "Last 7 days")
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(Array(dailyXP.prefix(7).enumerated()), id: \.offset) { index, xp in
                    VStack(spacing: 5) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(index == dailyXP.prefix(7).count - 1 ? AnyShapeStyle(LotusApp.aurora) : AnyShapeStyle(LotusApp.cobalt.opacity(0.14)))
                            .frame(height: max(8, CGFloat(xp) / CGFloat(maxXP) * 66))
                            .animation(.spring(response: 0.7, dampingFraction: 0.82), value: dailyXP)
                        Text(String(xp))
                            .font(.system(size: 8, weight: .medium, design: .rounded))
                            .foregroundStyle(LotusApp.muted)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 88, alignment: .bottom)
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 20)
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            statCard("Quizzes", "\(viewModel.stats.quizzesTaken)", "checkmark.circle.fill", LotusApp.cobalt)
            statCard("Correct", "\(viewModel.stats.correctAnswers)", "star.fill", LotusApp.mint)
            statCard("Saved words", "\(viewModel.stats.learnedWords)", "bookmark.fill", LotusApp.violet)
            statCard("Accuracy", "\(accuracy)%", "target", LotusApp.coral)
        }
    }

    private func statCard(_ title: String, _ value: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 11) {
            LotusIconBadge(icon: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(title)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .lotusGlassCard(cornerRadius: 17, opacity: 0.80, shadow: 0.04)
    }

    private var achievementsCard: some View {
        VStack(alignment: .leading, spacing: 13) {
            LotusSectionTitle(
                title: "Achievements",
                trailing: "\(viewModel.unlockedAchievementIds.count)/\(ProgressViewModel.allAchievements.count)"
            )
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(ProgressViewModel.allAchievements.prefix(8), id: \.id) { achievement in
                    let unlocked = viewModel.unlockedAchievementIds.contains(achievement.id)
                    VStack(spacing: 5) {
                        LotusIconBadge(
                            icon: achievement.icon,
                            color: unlocked ? LotusApp.amber : LotusApp.subtle,
                            size: 39
                        )
                        Text(achievement.title)
                            .font(.system(size: 7.5, weight: .medium, design: .rounded))
                            .foregroundStyle(unlocked ? LotusApp.ink : LotusApp.muted.opacity(0.56))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 20)
                    }
                }
            }
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 20)
    }

    private var motivationCard: some View {
        HStack(alignment: .top, spacing: 11) {
            LotusIconBadge(icon: "sparkles", color: LotusApp.violet, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text("Keep growing")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(motivationText)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 18)
    }

    private var streakMessage: String {
        switch viewModel.stats.currentStreak {
        case 0: return "Complete a lesson to begin."
        case 1: return "A beautiful start."
        case 2...6: return "Your rhythm is taking shape."
        case 7...13: return "One week of steady growth."
        default: return "Your consistency is blooming."
        }
    }

    private var streakIcon: String {
        switch viewModel.stats.currentStreak {
        case 0: return "moon.zzz.fill"
        case 1...3: return "leaf.fill"
        case 4...7: return "flame.fill"
        case 8...14: return "bolt.fill"
        default: return "trophy.fill"
        }
    }

    private var streakColor: Color {
        switch viewModel.stats.currentStreak {
        case 0: return LotusApp.subtle
        case 1...3: return LotusApp.mint
        case 4...7: return LotusApp.amber
        case 8...14: return LotusApp.cobalt
        default: return LotusApp.violet
        }
    }

    private var motivationText: String {
        if viewModel.stats.quizzesTaken == 0 {
            return "Take your first quiz. Every confident habit begins with one small session."
        }
        if viewModel.stats.learnedWords == 0 {
            return "Save useful words as you study and let your personal vocabulary take root."
        }
        return "You have learned \(viewModel.stats.learnedWords) words and completed \(viewModel.stats.quizzesTaken) quizzes. Keep the rhythm gentle and consistent."
    }

    private func weekdayLabel(_ offset: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -(6 - offset), to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        return formatter.string(from: date).uppercased()
    }
}
