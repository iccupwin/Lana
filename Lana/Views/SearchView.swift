import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = SearchViewModel()
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                // Top bar
                HStack(spacing: 12) {
                    // Search field
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(DarkDS.muted)
                        TextField("Search courses, words, grammar…", text: $vm.query)
                            .font(.system(size: 15))
                            .foregroundStyle(LotusApp.ink)
                            .tint(DarkDS.lime)
                            .focused($focused)
                            .submitLabel(.search)
                        if !vm.query.isEmpty {
                            Button { vm.query = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(DarkDS.muted)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))

                    Button("Cancel") {
                        focused = false
                        dismiss()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DarkDS.lime)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                Divider().background(DarkDS.border)

                ScrollView(.vertical, showsIndicators: false) {
                    if vm.query.count < 2 {
                        browseContent
                    } else {
                        resultsContent
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { focused = true }
        .navigationDestination(for: SearchResult.self) { result in
            destinationView(for: result)
        }
    }

    // MARK: - Browse (no query)

    private var browseContent: some View {
        VStack(alignment: .leading, spacing: 28) {
            // Hot Topics
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("Hot Topics", icon: "flame.fill", iconColor: .orange)

                VStack(spacing: 0) {
                    ForEach(vm.hotTopics, id: \.self) { topic in
                        Button {
                            vm.query = topic
                        } label: {
                            HStack {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DarkDS.lime)
                                    .frame(width: 28)
                                Text(topic)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(LotusApp.ink)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundStyle(DarkDS.muted)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)

                        if topic != vm.hotTopics.last {
                            Divider()
                                .background(DarkDS.border)
                                .padding(.leading, 60)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
            }

            // Categories
            VStack(alignment: .leading, spacing: 14) {
                sectionHeader("Browse by Category", icon: "square.grid.2x2.fill", iconColor: Color(red: 0.62, green: 0.38, blue: 0.98))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(vm.categories) { cat in
                        categoryCard(cat)
                    }
                }
            }

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // MARK: - Results

    private var resultsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            if vm.isSearching {
                HStack {
                    Spacer()
                    ProgressView().tint(DarkDS.lime)
                    Spacer()
                }
                .padding(.top, 60)
            } else if vm.results.isEmpty {
                emptyState
            } else {
                // Header
                Text("\(vm.results.count) results for \"\(vm.query)\"")
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    ForEach(vm.results) { result in
                        NavigationLink(value: result) {
                            resultRow(result)
                        }
                        .buttonStyle(.plain)

                        if result.id != vm.results.last?.id {
                            Divider()
                                .background(DarkDS.border)
                                .padding(.leading, 72)
                        }
                    }
                }
                .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
        }
    }

    // MARK: - Result Row

    private func resultRow(_ result: SearchResult) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accentColor(result.accentColor).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: result.icon)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(accentColor(result.accentColor))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(result.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .lineLimit(1)
                Text(result.subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Category Card

    private func categoryCard(_ cat: SearchTopic) -> some View {
        Button {
            vm.query = cat.title
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(hexColor(cat.colorHex).opacity(0.20))
                        .frame(width: 44, height: 44)
                    Image(systemName: cat.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(hexColor(cat.colorHex))
                }
                Text(cat.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(DarkDS.muted)
            Text("No results for \"\(vm.query)\"")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
            Text("Try a different word or browse categories below")
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
        .padding(.horizontal, 40)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(iconColor)
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(LotusApp.ink)
        }
    }

    // MARK: - Destination Routing

    @ViewBuilder
    private func destinationView(for result: SearchResult) -> some View {
        switch result.kind {
        case .grammar:
            grammarDestination(for: result)
        case .story:
            storyDestination(for: result)
        case .word, .idiom, .lesson:
            SavedWordsView(viewModel: SavedWordsViewModel(sqliteService: appState.sqliteService))
                .environmentObject(appState)
        }
    }

    @ViewBuilder
    private func grammarDestination(for result: SearchResult) -> some View {
        let repo = appState.contentRepository
        let topics = repo.fetchGrammarTopics()
        if let topic = topics.first(where: { "grammar_\($0.id)" == result.id }) {
            GrammarDetailView(topic: topic).environmentObject(appState)
        } else {
            GrammarView(viewModel: GrammarViewModel(repository: repo))
        }
    }

    @ViewBuilder
    private func storyDestination(for result: SearchResult) -> some View {
        let repo = appState.contentRepository
        let stories = repo.fetchStories()
        if let story = stories.first(where: { "story_\($0.id)" == result.id }) {
            StoryReaderView(viewModel: StoryReaderViewModel(story: story, sqliteService: appState.sqliteService))
                .environmentObject(appState)
        } else {
            StoriesView(repository: repo, sqliteService: appState.sqliteService)
                .environmentObject(appState)
        }
    }

    // MARK: - Helpers

    private func accentColor(_ name: String) -> Color {
        switch name {
        case "blue":   return Color(red: 0.22, green: 0.44, blue: 0.98)
        case "green":  return Color(red: 0.20, green: 0.78, blue: 0.43)
        case "purple": return Color(red: 0.62, green: 0.38, blue: 0.98)
        case "orange": return Color(red: 0.98, green: 0.60, blue: 0.18)
        case "lime":   return DarkDS.lime
        default:       return DarkDS.lime
        }
    }

    private func hexColor(_ hex: String) -> Color {
        switch hex {
        case "#5B8EF7": return Color(red: 0.36, green: 0.56, blue: 0.97)
        case "#F7A25B": return Color(red: 0.97, green: 0.64, blue: 0.36)
        case "#5BF7A2": return Color(red: 0.36, green: 0.97, blue: 0.64)
        case "#F75BB5": return Color(red: 0.97, green: 0.36, blue: 0.71)
        case "#A25BF7": return Color(red: 0.64, green: 0.36, blue: 0.97)
        case "#F7D55B": return Color(red: 0.97, green: 0.84, blue: 0.36)
        case "#5BE8F7": return Color(red: 0.36, green: 0.91, blue: 0.97)
        case "#F77A5B": return Color(red: 0.97, green: 0.48, blue: 0.36)
        default:        return DarkDS.lime
        }
    }
}

// MARK: - SearchResult Hashable (for NavigationLink)

extension SearchResult: Hashable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
