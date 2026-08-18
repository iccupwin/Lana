import SwiftUI

// MARK: - Explore Hub

struct ExploreHubView: View {
    @EnvironmentObject private var appState: AppState

    private let sections: [(icon: String, title: String, subtitle: String, count: String, gradient: LinearGradient)] = [
        ("textformat.abc",     "Grammar Guide",   "All tenses & rules",       "24 topics",  DarkDS.blueGradient),
        ("text.bubble.fill",   "Phrasebook",      "500+ essential phrases",   "12 categories", DarkDS.purpleGradient),
        ("books.vertical.fill","Vocabulary Sets", "Thematic word groups",     "8 sets",     DarkDS.orangeGradient),
        ("doc.text.fill",      "Read & Learn",    "Texts with vocab lookup",  "10 articles", DarkDS.limeGradient)
    ]

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    exploreHeader
                    featuredBanner
                    browseByTopic
                    sectionCards
                    wordOfDaySection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
    }

    // MARK: Header

    private var exploreHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Explore")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Text("Expand your knowledge")
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(.top, 16)
    }

    // MARK: Featured Banner

    private var featuredBanner: some View {
        NavigationLink {
            ReadAndLearnView().environmentObject(appState)
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: DarkDS.r)
                    .fill(DarkDS.blueGradient)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(LotusApp.ink.opacity(0.9))
                        Text("FEATURED THIS WEEK")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundStyle(LotusApp.ink.opacity(0.9))
                            .tracking(1.2)
                    }
                    Text("\"The Secret to Fluent English\"")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    HStack(spacing: 14) {
                        Label("B1 Level", systemImage: "chart.bar.fill")
                        Label("5 min read", systemImage: "clock")
                        Label("+20 XP", systemImage: "bolt.fill")
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(LotusApp.ink.opacity(0.7))
                }
                .padding(18)
            }
            .frame(height: 120)
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: Browse by Topic

    private let topics: [(icon: String, title: String, color: Color, dest: String)] = [
        ("briefcase.fill",      "Business",    Color(red: 0.36, green: 0.56, blue: 0.97), "grammar"),
        ("airplane",            "Travel",      Color(red: 0.97, green: 0.64, blue: 0.36), "lessons"),
        ("house.fill",          "Daily Life",  Color(red: 0.36, green: 0.97, blue: 0.64), "phrasebook"),
        ("bolt.fill",           "Slang",       Color(red: 0.97, green: 0.36, blue: 0.71), "vocab"),
        ("books.vertical.fill", "Academic",    Color(red: 0.64, green: 0.36, blue: 0.97), "read"),
        ("quote.bubble.fill",   "Idioms",      Color(red: 0.97, green: 0.84, blue: 0.36), "idioms"),
        ("globe",               "Culture",     Color(red: 0.36, green: 0.91, blue: 0.97), "stories"),
        ("textformat.abc",      "Grammar",     Color(red: 0.97, green: 0.48, blue: 0.36), "grammar"),
    ]

    private var browseByTopic: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Browse by Topic")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(topics, id: \.title) { topic in
                    NavigationLink {
                        topicDestination(topic.dest)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 11)
                                    .fill(topic.color.opacity(0.18))
                                    .frame(width: 40, height: 40)
                                Image(systemName: topic.icon)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(topic.color)
                            }
                            Text(topic.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(LotusApp.ink)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
        }
    }

    @ViewBuilder
    private func topicDestination(_ dest: String) -> some View {
        switch dest {
        case "grammar":   GrammarView(viewModel: GrammarViewModel(repository: appState.contentRepository))
        case "phrasebook": PhrasebookView().environmentObject(appState)
        case "vocab":     VocabTopicsView().environmentObject(appState)
        case "read":      ReadAndLearnView().environmentObject(appState)
        case "idioms":    IdiomGlossaryView(repository: appState.contentRepository).environmentObject(appState)
        case "stories":   StoriesView(repository: appState.contentRepository, sqliteService: appState.sqliteService).environmentObject(appState)
        case "lessons":   LessonsHomeView().environmentObject(appState)
        default:          EmptyView()
        }
    }

    // MARK: Section Cards

    private var sectionCards: some View {
        VStack(spacing: 14) {
            ForEach(sections.indices, id: \.self) { i in
                let s = sections[i]
                NavigationLink {
                    sectionDestination(i)
                } label: {
                    sectionRow(s)
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    private func sectionRow(_ s: (icon: String, title: String, subtitle: String, count: String, gradient: LinearGradient)) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(s.gradient)
                    .frame(width: 54, height: 54)
                Image(systemName: s.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(s.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text(s.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(s.count)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(DarkDS.card2))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(DarkDS.muted)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    @ViewBuilder
    private func sectionDestination(_ i: Int) -> some View {
        switch i {
        case 0: GrammarView(viewModel: GrammarViewModel(repository: appState.contentRepository))
        case 1: PhrasebookView().environmentObject(appState)
        case 2: VocabTopicsView().environmentObject(appState)
        case 3: ReadAndLearnView().environmentObject(appState)
        default: EmptyView()
        }
    }

    // MARK: Word of Day Section

    private var wordOfDaySection: some View {
        NavigationLink {
            WordOfDayView(viewModel: WordOfDayViewModel(
                repository: appState.contentRepository,
                sqliteService: appState.sqliteService
            ))
        } label: {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DarkDS.lime.opacity(0.18))
                        .frame(width: 54, height: 54)
                    Image(systemName: "sparkles")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(DarkDS.lime)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Word of the Day")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Text("Expand your daily vocabulary")
                        .font(.system(size: 12))
                        .foregroundStyle(DarkDS.muted)
                }
                Spacer()
                HStack(spacing: 6) {
                    Text("+5 XP")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(DarkDS.lime)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(DarkDS.lime.opacity(0.15)))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
        }
        .buttonStyle(PressScaleStyle())
    }
}
