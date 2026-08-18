import SwiftUI

// MARK: - Legacy aliases backed by the current Lotus design language
private let hBG    = LotusApp.pearl
private let hCard  = Color.white.opacity(0.86)
private let hLime  = LotusApp.cobalt
private let hMuted = LotusApp.muted

struct LessonsHomeView: View {
    @StateObject var viewModel = LessonsViewModel()
    @EnvironmentObject private var appState: AppState
    @AppStorage("userName") private var userName: String = ""

    @State private var selectedTab   = 0   // 0: Courses  1: AI Tutor  2: Explore
    @State private var selectedCat   = "Speaking"
    @State private var dailyQuests: [DailyQuest] = []

    // Practice tab data
    @StateObject private var leagueVM = LeagueViewModel(sqliteService: SQLiteService.shared)
    @ObservedObject private var hearts = HeartsService.shared
    @State private var currentStreak  = 0
    @State private var dailyXP: [Int] = Array(repeating: 0, count: 7)
    @State private var streakPulse    = false

    private let categories = ["Reading", "Speaking", "Writing", "Listening", "Grammar"]

    private var completedCount: Int { appState.completedLessonIds.count }
    private var completedPct: Int {
        let t = viewModel.lessons.count
        return t > 0 ? Int(Double(completedCount) / Double(t) * 100) : 0
    }
    private var rating: String {
        let base = 5.0 + Double(appState.levelInfo.level) * 0.5
        return String(format: "%.1f", min(9.9, base))
    }
    private var nextLesson: LessonCard {
        viewModel.lessons.first { !appState.completedLessonIds.contains($0.id) } ?? viewModel.lessons[0]
    }
    private var todayXP: Int { dailyXP.last ?? 0 }
    private let dailyGoalXP = 100
    private var missionProgress: CGFloat { min(1, CGFloat(todayXP) / CGFloat(dailyGoalXP)) }
    private var tasksCompleted: Int { [10,25,50,75,100].filter { todayXP >= $0 }.count }

    var body: some View {
        ZStack {
            hBG.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    topBar
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    greetingRow
                        .padding(.horizontal, 20)
                        .padding(.top, 18)

                    tabBar
                        .padding(.top, 22)

                    Group {
                        switch selectedTab {
                        case 1:  aiTutorContent
                        case 2:  exploreContent
                        default: lessonsContent
                        }
                    }
                    .padding(.top, 22)
                }
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.refreshAll()
            dailyQuests   = QuestService.shared.generateDailyQuests()
            currentStreak = appState.sqliteService.fetchProgress().currentStreak
            dailyXP       = appState.sqliteService.fetchDailyXP()
            leagueVM.load()
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.5)) {
                streakPulse = true
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Avatar
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(LotusApp.ink.opacity(0.7))
                )
                .overlay(Circle().strokeBorder(Color.white.opacity(0.15), lineWidth: 1))

            Spacer()

            HStack(spacing: 10) {
                navIconButton("bubble.left")
                navIconButton("bell")
            }
        }
    }

    private func navIconButton(_ icon: String) -> some View {
        Circle()
            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1.5)
            .frame(width: 42, height: 42)
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(LotusApp.ink)
            )
    }

    // MARK: - Greeting

    private var greetingRow: some View {
        Text("Hello, \(userName.isEmpty ? "there" : userName)")
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(LotusApp.ink)
    }

    // MARK: - Internal Tab Bar (underline style)

    private var tabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabItem("Courses",  0, badge: nil)
                tabItem("AI Tutor", 1, badge: nil)
                tabItem("Explore",  2, badge: nil)
            }
            .padding(.horizontal, 20)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
        }
    }

    private func tabItem(_ title: String, _ index: Int, badge: Int?) -> some View {
        let active = selectedTab == index
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = index }
        } label: {
            VStack(spacing: 9) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(active ? LotusApp.ink : LotusApp.muted)
                    if let b = badge {
                        Text("\(b)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Capsule().fill(hLime))
                    }
                }
                Rectangle()
                    .fill(active ? hLime : Color.clear)
                    .frame(height: 2)
                    .cornerRadius(1)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Lessons Tab

    private var lessonsContent: some View {
        VStack(alignment: .leading, spacing: 22) {
            statsRow
            featuredCard
            categorySection
            courseCardsScroll
        }
    }

    // Stats row: 2 cards
    private var statsRow: some View {
        HStack(spacing: 12) {
            // Completed
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Completed ")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(hMuted)
                    Text("(\(completedPct)%)")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(hLime)
                }
                Text("\(completedCount)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(hCard))

            // Rating
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    Text("Pupil ")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(hMuted)
                    Text("rating")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(hLime)
                }
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(hLime)
                    Text(rating)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
        }
        .padding(.horizontal, 20)
    }

    // Featured course card
    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Tutor row
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 17))
                    .foregroundStyle(hLime)
                Group {
                    Text("Tutor  ").foregroundStyle(hMuted) +
                    Text("AI Learning Path").foregroundStyle(hMuted)
                }
                .font(.system(size: 13, weight: .medium))
            }

            // Title
            NavigationLink { LessonDetailView(card: nextLesson) } label: {
                VStack(alignment: .leading, spacing: 14) {
                    Text(nextLesson.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // Info chips
                    HStack(spacing: 20) {
                        infoChip(label: "Lessons", value: "\(viewModel.lessons.count)+")
                        infoChip(label: "Level",   value: "A1 → B2")
                        infoChip(label: "Rating",  value: "4.8")
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(hCard))
        .padding(.horizontal, 20)
    }

    private func infoChip(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(hMuted)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LotusApp.ink.opacity(0.75))
        }
    }

    // Category pills
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose category")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                selectedCat = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(selectedCat == cat ? .white : LotusApp.muted)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 11)
                                .background(
                                    Capsule().fill(selectedCat == cat ? hLime : DarkDS.card2)
                                )
                                .overlay(
                                    Capsule().strokeBorder(
                                        selectedCat == cat ? Color.clear : DarkDS.border,
                                        lineWidth: 1
                                    )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 2)
            }
        }
    }

    // Horizontal course cards
    private var courseCardsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Array(viewModel.lessons.enumerated()), id: \.element.id) { i, lesson in
                    NavigationLink { LessonDetailView(card: lesson) } label: {
                        courseCard(lesson: lesson, accent: i % 3 == 1)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
        }
    }

    private func courseCard(lesson: LessonCard, accent: Bool) -> some View {
        let isDone = appState.completedLessonIds.contains(lesson.id)
        let level = isDone ? "Completed" : (viewModel.lessons.firstIndex(where: { $0.id == lesson.id }) ?? 0) < 3 ? "Beginner" : "Intermediate"

        return VStack(alignment: .leading, spacing: 0) {
            // Level + price
            HStack {
                Text(level)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(accent ? .white.opacity(0.76) : hMuted)
                Spacer()
                Text("$90")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(accent ? .white : LotusApp.ink)
            }
            .padding(.bottom, 14)

            // Title
            Text(lesson.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(accent ? .white : LotusApp.ink)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Certificate row
            HStack(spacing: 6) {
                Image(systemName: "rosette")
                    .font(.system(size: 13))
                    .foregroundStyle(accent ? .black.opacity(0.5) : hMuted)
                Text("Certificate")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(accent ? .black.opacity(0.5) : hMuted)
                Spacer()

                CircularProgressRing(
                    progress: isDone ? 1.0 : 0.0,
                    size: 32,
                    lineWidth: 2.5,
                    trackColor: Color.white.opacity(0.15),
                    ringColor: accent ? Color.black.opacity(0.5) : DarkDS.lime,
                    showCheckWhenComplete: true
                )
            }
        }
        .padding(18)
        .frame(width: 160, height: 210)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(accent ? hLime : hCard)
        )
    }

    // MARK: - AI Tutor Tab

    private var aiTutorContent: some View {
        VStack(spacing: 20) {
            // Daily challenge teaser
            NavigationLink {
                AITutorHubView().environmentObject(appState)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(LinearGradient(
                            colors: [DarkDS.lime, Color(red: 0.55, green: 0.80, blue: 0.10)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ))
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.6))
                            Text("TODAY'S CHALLENGE")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundStyle(.white.opacity(0.6))
                                .tracking(1.2)
                        }
                        Text(dailyChallenge)
                            .font(.system(size: 19, weight: .bold))
                            .foregroundStyle(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Start challenge")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "arrow.right")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(.black.opacity(0.12)))
                    }
                    .padding(20)
                }
                .frame(minHeight: 150)
            }
            .buttonStyle(PressScaleStyle())

            // Mode cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                NavigationLink {
                    FreeTalkView(topic: "Free Talk", prompt: "Hi! I'm your AI English coach. What would you like to talk about today?")
                        .environmentObject(appState)
                } label: { aiModeCard("bubble.left.fill", "Free Talk", "Chat about anything", "+15 XP", DarkDS.blueGradient) }
                .buttonStyle(PressScaleStyle())

                NavigationLink {
                    TopicChatPickerView().environmentObject(appState)
                } label: { aiModeCard("text.bubble.fill", "Topic Chat", "Choose a topic", "+20 XP", DarkDS.purpleGradient) }
                .buttonStyle(PressScaleStyle())

                NavigationLink {
                    SpeakingPracticeView().environmentObject(appState)
                } label: { aiModeCard("waveform.circle.fill", "Speaking", "Pronunciation drills", "+25 XP", DarkDS.limeGradient) }
                .buttonStyle(PressScaleStyle())

                NavigationLink {
                    WritingCheckView().environmentObject(appState)
                } label: { aiModeCard("pencil.line", "Writing", "Get AI feedback", "+30 XP", DarkDS.orangeGradient) }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    private var dailyChallenge: String {
        let challenges = [
            "Describe your perfect weekend in 3 sentences",
            "Talk about a skill you want to learn",
            "Explain what you did yesterday",
            "Describe your hometown to a stranger",
            "Tell about your favourite movie"
        ]
        let day = Calendar.current.component(.day, from: Date())
        return challenges[day % challenges.count]
    }

    private func aiModeCard(_ icon: String, _ title: String, _ subtitle: String, _ xp: String, _ gradient: LinearGradient) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(gradient)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
                Spacer()
                Text(xp)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(hMuted)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(Capsule().fill(Color.white.opacity(0.07)))
            }
            Text(title).font(.system(size: 15, weight: .bold)).foregroundStyle(LotusApp.ink)
            Text(subtitle).font(.system(size: 12)).foregroundStyle(hMuted).lineLimit(1)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
    }

    // MARK: - Explore Tab

    private var exploreContent: some View {
        VStack(spacing: 14) {
            exploreSectionRow("textformat.abc",      "Grammar Guide",   "All tenses & rules",       "24 topics",     DarkDS.blueGradient)   { GrammarView(viewModel: GrammarViewModel(repository: appState.contentRepository)) }
            exploreSectionRow("text.bubble.fill",    "Phrasebook",      "500+ essential phrases",   "12 categories", DarkDS.purpleGradient)  { PhrasebookView().environmentObject(appState) }
            exploreSectionRow("books.vertical.fill", "Vocabulary Sets", "Thematic word groups",     "8 sets",        DarkDS.orangeGradient)  { VocabTopicsView().environmentObject(appState) }
            exploreSectionRow("doc.text.fill",       "Read & Learn",    "Texts with vocab lookup",  "10 articles",   DarkDS.limeGradient)    { ReadAndLearnView().environmentObject(appState) }
            exploreSectionRow("sparkles",            "Word of the Day", "Expand your daily vocab",  "+5 XP",         LinearGradient(colors: [DarkDS.lime, Color(red: 0.55, green: 0.80, blue: 0.10)], startPoint: .topLeading, endPoint: .bottomTrailing)) {
                WordOfDayView(viewModel: WordOfDayViewModel(repository: appState.contentRepository, sqliteService: appState.sqliteService))
            }
        }
    }

    @ViewBuilder
    private func exploreSectionRow<Dest: View>(
        _ icon: String, _ title: String, _ subtitle: String, _ count: String,
        _ gradient: LinearGradient,
        @ViewBuilder dest: () -> Dest
    ) -> some View {
        NavigationLink(destination: dest) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(gradient)
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(hMuted)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(count)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(hMuted)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.07)))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(hMuted)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: - Practice helpers (kept for Quick Play grid links)
    // These are referenced by quickPlayGrid used inside the Courses tab's lessonsContent area.

    private var practiceContent: some View {
        VStack(spacing: 20) {
            dailyMissionCard
            streakCalendar
            quickPlayGrid
            leagueTeaserCard
            if !dailyQuests.isEmpty {
                DailyQuestsCard(quests: dailyQuests).padding(.horizontal, 20)
            }
        }
    }

    private var dailyMissionCard: some View {
        let isComplete = todayXP >= dailyGoalXP
        let lesson = viewModel.lessons.first ?? viewModel.lessons[0]

        return ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24)
                .fill(LinearGradient(
                    colors: [Color(red: 0.17, green: 0.34, blue: 0.90), Color(red: 0.28, green: 0.16, blue: 0.68)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .shadow(color: Color(red: 0.17, green: 0.34, blue: 0.90).opacity(0.35), radius: 16, y: 6)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 5) {
                            Image(systemName: isComplete ? "checkmark.seal.fill" : "target")
                                .font(.system(size: 10, weight: .black))
                            Text(isComplete ? "MISSION COMPLETE!" : "DAILY MISSION")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .tracking(1.5)
                        }
                        .foregroundStyle(LotusApp.ink.opacity(0.8))
                        Text(isComplete ? "Amazing work today!" : "Earn \(dailyGoalXP) XP today")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(LotusApp.ink)
                    }
                    Spacer()
                    ZStack {
                        Circle().fill(Color.white.opacity(0.20)).frame(width: 54, height: 54)
                        Image(systemName: isComplete ? "checkmark.seal.fill" : lesson.iconSystemName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(LotusApp.ink)
                    }
                }
                .padding(.bottom, 18)

                HStack(spacing: 8) {
                    Text("\(tasksCompleted)/5 tasks")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink.opacity(0.75))
                    HStack(spacing: 6) {
                        ForEach(0..<5, id: \.self) { i in
                            Circle()
                                .fill(i < tasksCompleted ? Color.white : Color.white.opacity(0.30))
                                .frame(width: 9, height: 9)
                        }
                    }
                }
                .padding(.bottom, 16)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.20)).frame(height: 8)
                        Capsule().fill(Color.white)
                            .frame(width: geo.size.width * missionProgress, height: 8)
                            .animation(.spring(response: 0.8, dampingFraction: 0.75), value: missionProgress)
                    }
                }
                .frame(height: 8).padding(.bottom, 18)

                NavigationLink { LessonDetailView(card: lesson) } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "bolt.fill").font(.system(size: 15, weight: .bold))
                        Text(isComplete ? "Continue Learning" : "Start  +\(dailyGoalXP) XP")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Spacer()
                        Image(systemName: "arrow.right").font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Color(red: 0.17, green: 0.34, blue: 0.90))
                    .padding(.horizontal, 18).padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 14).fill(.white))
                }
                .buttonStyle(PressScaleStyle())
            }
            .padding(22)
        }
        .padding(.horizontal, 20)
    }

    private var streakCalendar: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text(currentStreak > 0 ? "\(currentStreak)-Day Streak" : "Streak Calendar")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                }
                Spacer()
                if currentStreak > 0 {
                    Text("Don't lose it!")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                }
            }

            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    let active  = i < dailyXP.count && dailyXP[i] > 0
                    let isToday = i == 6
                    VStack(spacing: 6) {
                        Text(weekDayLabel(i))
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(isToday ? hLime : hMuted)
                        ZStack {
                            Circle()
                                .fill(active
                                      ? (isToday ? hLime : Color(red: 0.20, green: 0.78, blue: 0.43))
                                      : Color.white.opacity(0.08))
                                .frame(width: 36, height: 36)
                            if active {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            } else if isToday {
                                Circle().strokeBorder(hLime, lineWidth: 2).frame(width: 36, height: 36)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
        .padding(.horizontal, 20)
    }

    private func weekDayLabel(_ index: Int) -> String {
        let daysAgo = 6 - index
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let f = DateFormatter(); f.dateFormat = "E"
        return String(f.string(from: date).prefix(1))
    }

    private var quickPlayGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Play")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                Text("tap to earn XP")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(hMuted)
            }
            .padding(.horizontal, 20)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickCard("bolt.fill",        "Match Madness",    "Tap pairs fast",                     hLime,                                         "+30 XP") { MatchMadnessView().environmentObject(appState) }
                quickCard("puzzlepiece.fill", "Sentence Builder", "Arrange words",      Color(red: 0.62, green: 0.38, blue: 0.98), "+25 XP") { SentenceBuilderView().environmentObject(appState) }
                quickCard("target",           "Quiz",             "Test knowledge",     Color(red: 0.22, green: 0.44, blue: 0.98), "+45 XP") { QuizListView() }
                quickCard("message.fill",     "Dialogue",         "Real conversations", Color(red: 0.20, green: 0.78, blue: 0.43), "+20 XP") { DialoguePracticeView().environmentObject(appState) }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    private func quickCard<Dest: View>(
        _ icon: String, _ title: String, _ subtitle: String,
        _ color: Color, _ xp: String,
        @ViewBuilder dest: () -> Dest
    ) -> some View {
        NavigationLink(destination: dest) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    ZStack {
                        Circle().fill(color.opacity(0.22)).frame(width: 42, height: 42)
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(color)
                    }
                    Spacer()
                    Text(xp)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink.opacity(0.6))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().fill(color.opacity(0.3)))
                }
                Text(title).font(.system(size: 14, weight: .bold, design: .rounded)).foregroundStyle(LotusApp.ink).lineLimit(1)
                Text(subtitle).font(.system(size: 11, weight: .regular, design: .rounded)).foregroundStyle(hMuted).lineLimit(1)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
        }
        .buttonStyle(PressScaleStyle())
    }

    private var leagueTeaserCard: some View {
        let rank   = leagueVM.userRank
        let sorted = leagueVM.players
        let myXP   = sorted.first(where: { $0.isCurrentUser })?.weeklyXP ?? 0
        let above  = sorted.first(where: { !$0.isCurrentUser && $0.weeklyXP > myXP })
        let gap    = (above?.weeklyXP ?? myXP) - myXP

        return NavigationLink {
            LeagueView(sqliteService: appState.sqliteService).environmentObject(appState)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        colors: [Color(red: 0.55, green: 0.40, blue: 0.10), Color(red: 0.28, green: 0.22, blue: 0.06)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .shadow(color: Color.yellow.opacity(0.20), radius: 10, y: 4)

                VStack(spacing: 0) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 5) {
                                Image(systemName: "trophy.fill").font(.system(size: 10, weight: .black))
                                Text("BRONZE LEAGUE").font(.system(size: 10, weight: .black, design: .rounded)).tracking(1.5)
                            }
                            .foregroundStyle(LotusApp.ink.opacity(0.75))
                            Text("You're #\(rank) this week").font(.system(size: 20, weight: .bold)).foregroundStyle(LotusApp.ink)
                            if let above = above, rank > 1 {
                                Text("\(above.name) is ahead by \(gap) XP").font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(LotusApp.ink.opacity(0.65))
                            } else {
                                Text("You're leading!").font(.system(size: 12, weight: .medium, design: .rounded)).foregroundStyle(LotusApp.ink.opacity(0.65))
                            }
                        }
                        Spacer()
                        ZStack {
                            Circle().fill(Color.yellow.opacity(0.20)).frame(width: 56, height: 56)
                            Text("#\(rank)").font(.system(size: 20, weight: .black, design: .rounded)).foregroundStyle(.yellow)
                        }
                    }
                    .padding(.bottom, 14)

                    if rank > 1, let above = above {
                        let progress = max(0, CGFloat(myXP) / CGFloat(above.weeklyXP))
                        VStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.15)).frame(height: 6)
                                    Capsule().fill(Color.yellow).frame(width: geo.size.width * progress, height: 6)
                                }
                            }
                            .frame(height: 6)
                            HStack {
                                Text("Your XP: \(myXP)").font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(LotusApp.ink.opacity(0.6))
                                Spacer()
                                Text("Earn \(gap) more →").font(.system(size: 10, weight: .semibold, design: .rounded)).foregroundStyle(.yellow.opacity(0.85))
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .buttonStyle(PressScaleStyle())
        .padding(.horizontal, 20)
    }

    // MARK: - Progress Tab

    private var progressContent: some View {
        VStack(spacing: 16) {
            NavigationLink {
                ProgressScreen(viewModel: ProgressViewModel(sqliteService: appState.sqliteService))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Progress")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(LotusApp.ink)
                        Text("View detailed stats")
                            .font(.system(size: 13))
                            .foregroundStyle(hMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(hMuted)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            NavigationLink {
                SavedWordsView(viewModel: SavedWordsViewModel(sqliteService: appState.sqliteService))
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Saved Words")
                            .font(.system(size: 18, weight: .bold)).foregroundStyle(LotusApp.ink)
                        Text("Review your vocabulary")
                            .font(.system(size: 13)).foregroundStyle(hMuted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(hMuted)
                }
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 18).fill(hCard))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    NavigationStack {
        LessonsHomeView().environmentObject(AppState())
    }
}
