import SwiftUI

struct PracticeHubView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var hearts = HeartsService.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var flowerIsAlive = false

    private let coreSections: [(title: String, subtitle: String, icon: String, color: Color, dest: String, xp: String)] = [
        ("Grammar", "10 topics · all tenses", "textformat.abc", LotusApp.cobalt, "grammar", "+15 XP"),
        ("Listening", "8 exercises · real audio", "headphones", LotusApp.violet, "listening", "+25 XP"),
        ("Movies", "8 iconic scenes", "film.fill", LotusApp.amber, "movies", "Free")
    ]

    private let extraSections: [(title: String, subtitle: String, icon: String, color: Color, dest: String, xp: String)] = [
        ("Stories", "4 stories · A1 → B2", "books.vertical.fill", LotusApp.amber, "stories", "+40 XP"),
        ("Daily Phrase", "Idioms & phrasal verbs", "text.bubble.fill", LotusApp.violet, "daily_phrase", "+10 XP"),
        ("Speed Review", "Timed flashcard quiz", "bolt.fill", LotusApp.cobalt, "speed_review", "+15 XP"),
        ("Pronunciation", "Practice speaking aloud", "waveform", LotusApp.mint, "pronunciation", "+10 XP"),
        ("Word Scramble", "Unscramble the letters", "character.cursor.ibeam", LotusApp.coral, "word_scramble", "+15 XP"),
        ("Fill the Blank", "Complete the sentences", "rectangle.and.pencil.and.ellipsis", LotusApp.violet, "fill_blank", "+20 XP"),
        ("Vocab Topics", "6 themes · 48 words", "books.vertical.fill", LotusApp.cobalt, "vocab_topics", "+10 XP"),
        ("Mistake Review", "Retry your wrong answers", "arrow.uturn.backward.circle.fill", LotusApp.amber, "mistakes", "Fix it"),
        ("Typing Practice", "Type the missing word", "keyboard.fill", LotusApp.mint, "typing", "+25 XP"),
        ("Idioms", "24 expressions", "quote.bubble.fill", LotusApp.violet, "idioms", "Free"),
        ("Audio Quiz", "Listen and choose", "speaker.wave.2.fill", LotusApp.cobalt, "audio_quiz", "+20 XP"),
        ("Match Madness", "Match pairs quickly", "square.grid.2x2.fill", LotusApp.mint, "match_madness", "+30 XP"),
        ("Sentence Builder", "Arrange words in order", "text.alignleft", LotusApp.violet, "sentence_builder", "+25 XP"),
        ("Dialogue", "Real-life conversations", "message.fill", LotusApp.cobalt, "dialogue", "+20 XP"),
        ("League", "Compete this week", "trophy.fill", LotusApp.amber, "league", "Rank up")
    ]

    var body: some View {
        LotusAppScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 17) {
                    LotusPageHeader(
                        title: "Practice",
                        subtitle: "Sharpen your skills",
                        actionIcon: "bolt.fill",
                        action: { HapticService.shared.selection() }
                    )
                    levelCard
                    heartsCard
                    if hearts.isEmpty { outOfHeartsCard }
                    LotusSectionTitle(title: "Core practice")
                    coreFlower
                    LotusSectionTitle(title: "Explore more")
                    extraList
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.refreshAll()
            startFlowerAnimation()
        }
        .navigationDestination(for: String.self) { value in
            destination(value)
        }
    }

    private var levelCard: some View {
        HStack(spacing: 13) {
            LotusIconBadge(icon: appState.levelInfo.icon, color: LotusApp.mint, size: 44)
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(appState.levelInfo.name)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Spacer()
                    Text("\(appState.totalXP) XP")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.cobalt)
                }
                LotusProgressBar(progress: appState.levelInfo.progress, height: 6)
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19)
    }

    private var heartsCard: some View {
        HStack(spacing: 7) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < hearts.hearts ? "heart.fill" : "heart")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(index < hearts.hearts ? LotusApp.danger : LotusApp.subtle.opacity(0.58))
                    .symbolEffect(.pulse, value: hearts.hearts)
            }
            Spacer()
            Text(hearts.isEmpty ? "Lives will refill" : "Ready to practice")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(LotusApp.muted)
        }
        .padding(.horizontal, 15)
        .frame(height: 46)
        .lotusGlassCard(cornerRadius: 17, opacity: 0.78, shadow: 0.04)
    }

    private var outOfHeartsCard: some View {
        HStack(spacing: 11) {
            LotusIconBadge(icon: "heart.slash.fill", color: LotusApp.danger, size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text("Take a short pause")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text("Your lives refill automatically.")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 18)
    }

    private var coreFlower: some View {
        ZStack {
            LotusAssetSurface(name: "LotusPracticePetals", height: 306, cornerRadius: 27)
                .opacity(0.82)
                .scaleEffect(flowerIsAlive ? 1 : 0.975)
                .rotationEffect(.degrees(flowerIsAlive ? 0.8 : -0.8))
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 4.2).repeatForever(autoreverses: true),
                    value: flowerIsAlive
                )

            VStack(spacing: 54) {
                HStack(spacing: 10) {
                    coreCard(coreSections[0])
                    coreCard(coreSections[1])
                }
                coreCard(coreSections[2])
                    .frame(maxWidth: 158)
            }
            .padding(13)
        }
        .frame(height: 306)
        .lotusGlassCard(cornerRadius: 27, opacity: 0.72)
    }

    private func coreCard(_ section: (title: String, subtitle: String, icon: String, color: Color, dest: String, xp: String)) -> some View {
        NavigationLink(value: section.dest) {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    LotusIconBadge(icon: section.icon, color: section.color, size: 38)
                    Spacer()
                    Text(section.xp)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .foregroundStyle(section.color)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(section.color.opacity(0.09)))
                }
                Text(section.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(section.subtitle)
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(11)
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.88))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(section.color.opacity(0.14), lineWidth: 1)
                    }
                    .shadow(color: LotusApp.ink.opacity(0.06), radius: 10, y: 5)
            }
        }
        .buttonStyle(PressScaleStyle())
    }

    private var extraList: some View {
        LazyVStack(spacing: 10) {
            ForEach(extraSections, id: \.dest) { section in
                NavigationLink(value: section.dest) {
                    HStack(spacing: 12) {
                        LotusIconBadge(icon: section.icon, color: section.color, size: 43)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(section.title)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(LotusApp.ink)
                            Text(section.subtitle)
                                .font(.system(size: 10, weight: .regular, design: .rounded))
                                .foregroundStyle(LotusApp.muted)
                                .lineLimit(1)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 5) {
                            Text(section.xp)
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundStyle(section.color)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(LotusApp.subtle)
                        }
                    }
                    .padding(13)
                    .lotusGlassCard(cornerRadius: 18, opacity: 0.78, shadow: 0.045)
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    private func startFlowerAnimation() {
        guard !reduceMotion else {
            flowerIsAlive = true
            return
        }
        flowerIsAlive = false
        DispatchQueue.main.async { flowerIsAlive = true }
    }

    @ViewBuilder
    private func destination(_ value: String) -> some View {
        switch value {
        case "grammar": GrammarView(viewModel: GrammarViewModel(repository: appState.contentRepository))
        case "listening": ListeningView(viewModel: ListeningViewModel(repository: appState.contentRepository))
        case "movies": MoviesView(viewModel: MoviesViewModel(repository: appState.contentRepository))
        case "stories": StoriesView(repository: appState.contentRepository, sqliteService: appState.sqliteService).environmentObject(appState)
        case "daily_phrase": DailyPhraseView(repository: appState.contentRepository).environmentObject(appState)
        case "speed_review": SpeedReviewView(sqliteService: appState.sqliteService).environmentObject(appState)
        case "league": LeagueView(sqliteService: appState.sqliteService).environmentObject(appState)
        case "pronunciation": PronunciationPracticeView(sqliteService: appState.sqliteService).environmentObject(appState)
        case "word_scramble": WordScrambleView(sqliteService: appState.sqliteService).environmentObject(appState)
        case "fill_blank": FillBlankView().environmentObject(appState)
        case "vocab_topics": VocabTopicsView().environmentObject(appState)
        case "mistakes": MistakeReviewView(viewModel: MistakeReviewViewModel(sqliteService: appState.sqliteService)).environmentObject(appState)
        case "typing": TypingPracticeView().environmentObject(appState)
        case "idioms": IdiomGlossaryView(repository: appState.contentRepository).environmentObject(appState)
        case "audio_quiz": AudioQuizView().environmentObject(appState)
        case "match_madness": MatchMadnessView().environmentObject(appState)
        case "sentence_builder": SentenceBuilderView().environmentObject(appState)
        case "dialogue": DialoguePracticeView().environmentObject(appState)
        default: EmptyView()
        }
    }
}
