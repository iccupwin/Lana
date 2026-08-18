import SwiftUI

private enum SortOption: String, CaseIterable {
    case dateAdded = "Date Added"
    case alphabetical = "A → Z"
    case mastery = "Mastery"
    case dueFirst = "Due First"
}

private enum FilterOption: String, CaseIterable {
    case all = "All"
    case due = "Due"
    case new = "New"
    case learning = "Learning"
    case familiar = "Familiar"
    case mastered = "Mastered"
}

struct SavedWordsView: View {
    @ObservedObject var viewModel: SavedWordsViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showAddWord = false
    @State private var showSpeedReview = false
    @State private var searchText = ""
    @State private var selectedFilter = FilterOption.all
    @State private var selectedSort = SortOption.dateAdded
    @State private var showSortPicker = false
    @State private var selectedWord: SavedWord?
    @State private var seedIsAlive = false

    private var masteryMap: [String: WordMasteryLevel] {
        Dictionary(uniqueKeysWithValues: viewModel.savedWords.map { word in
            (word.id, WordMasteryLevel.level(for: appState.sqliteService.fetchWordRepetitions(wordId: word.id)))
        })
    }

    private var filteredAndSorted: [SavedWord] {
        var words = viewModel.savedWords

        switch selectedFilter {
        case .all: break
        case .due: words = words.filter { viewModel.isDue($0) }
        case .new: words = words.filter { masteryMap[$0.id] == .new }
        case .learning: words = words.filter { masteryMap[$0.id] == .learning }
        case .familiar: words = words.filter { masteryMap[$0.id] == .familiar }
        case .mastered: words = words.filter { masteryMap[$0.id] == .mastered }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            words = words.filter {
                $0.word.lowercased().contains(query) || $0.translation.lowercased().contains(query)
            }
        }

        switch selectedSort {
        case .dateAdded: break
        case .alphabetical: words.sort { $0.word.lowercased() < $1.word.lowercased() }
        case .mastery: words.sort { (masteryMap[$0.id]?.rawValue ?? 0) < (masteryMap[$1.id]?.rawValue ?? 0) }
        case .dueFirst: words.sort { viewModel.isDue($0) && !viewModel.isDue($1) }
        }

        return words
    }

    var body: some View {
        LotusAppScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    pageHeader
                    if viewModel.savedWords.isEmpty {
                        emptyState
                    } else {
                        statsRow
                        masteryCard
                        if viewModel.dueCount > 0 { reviewBanner }
                        searchBar
                        filterPills
                        wordList
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.load()
            startSeedAnimation()
        }
        .sheet(isPresented: $showAddWord) {
            CustomWordInputView(onSave: { viewModel.load() })
                .environmentObject(appState)
        }
        .navigationDestination(isPresented: $showSpeedReview) {
            SpeedReviewView(sqliteService: appState.sqliteService)
                .environmentObject(appState)
        }
        .sheet(item: $selectedWord) { word in
            wordDetailSheet(word)
        }
        .confirmationDialog("Sort By", isPresented: $showSortPicker, titleVisibility: .visible) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button(option.rawValue) { selectedSort = option }
            }
        }
    }

    private var pageHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MY VOCABULARY")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .tracking(1.6)
                    .foregroundStyle(LotusApp.muted)
                Text("Saved Words")
                    .font(.system(size: 31, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Button { showSortPicker = true } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(LotusApp.cobalt)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.white.opacity(0.86)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
            }
            .buttonStyle(PressScaleStyle())

            Button { showAddWord = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(LotusApp.aurora))
                    .shadow(color: LotusApp.violet.opacity(0.22), radius: 12, y: 6)
            }
            .buttonStyle(PressScaleStyle())
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            LotusAssetSurface(name: "LotusSavedSeed", height: 300, cornerRadius: 28)
                .scaleEffect(seedIsAlive ? 1 : 0.975)
                .offset(y: seedIsAlive ? -3 : 3)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 3.8).repeatForever(autoreverses: true),
                    value: seedIsAlive
                )
                .accessibilityHidden(true)

            Text("No saved words yet")
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(LotusApp.ink)

            Text("Words you collect will grow here.\nSave them while learning or add your own.")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundStyle(LotusApp.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            LotusGradientButton(title: "Add your first word", icon: "plus") {
                showAddWord = true
            }
            .frame(maxWidth: 260)
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .lotusGlassCard(cornerRadius: 28, opacity: 0.78)
    }

    private var statsRow: some View {
        let mastered = masteryMap.values.filter { $0 == .mastered }.count

        return HStack(spacing: 9) {
            statCell(value: "\(viewModel.savedWords.count)", label: "Total", icon: "bookmark.fill", color: LotusApp.violet)
            statCell(value: "\(mastered)", label: "Mastered", icon: "checkmark.circle.fill", color: LotusApp.mint)
            statCell(value: "\(viewModel.dueCount)", label: "Due", icon: "clock.fill", color: viewModel.dueCount > 0 ? LotusApp.amber : LotusApp.subtle)
        }
    }

    private func statCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundStyle(LotusApp.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .background(RoundedRectangle(cornerRadius: 17).fill(color.opacity(0.075)))
        .lotusGlassCard(cornerRadius: 17, opacity: 0.62, shadow: 0.035)
    }

    private var masteryCard: some View {
        let total = max(1, viewModel.savedWords.count)
        let mastered = masteryMap.values.filter { $0 == .mastered }.count

        return VStack(alignment: .leading, spacing: 10) {
            LotusSectionTitle(title: "Vocabulary growth", trailing: "\(mastered) mastered")
            LotusProgressBar(progress: Double(mastered) / Double(total), height: 8)
            HStack {
                masteryLegend(.new)
                masteryLegend(.learning)
                masteryLegend(.familiar)
                masteryLegend(.mastered)
            }
        }
        .padding(15)
        .lotusGlassCard(cornerRadius: 20)
    }

    private func masteryLegend(_ level: WordMasteryLevel) -> some View {
        HStack(spacing: 4) {
            Circle().fill(level.color).frame(width: 6, height: 6)
            Text("\(masteryMap.values.filter { $0 == level }.count)")
                .font(.system(size: 9, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.muted)
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel("\(level.label): \(masteryMap.values.filter { $0 == level }.count)")
    }

    private var reviewBanner: some View {
        Button {
            guard viewModel.savedWords.count >= 4 else { return }
            showSpeedReview = true
        } label: {
            HStack(spacing: 12) {
                LotusIconBadge(icon: "bolt.fill", color: LotusApp.cobalt, size: 46)
                VStack(alignment: .leading, spacing: 3) {
                    Text("\(viewModel.dueCount) word\(viewModel.dueCount == 1 ? "" : "s") ready to review")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text("A quick review keeps the petals open")
                        .font(.system(size: 10, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(LotusApp.cobalt)
            }
            .padding(14)
            .lotusGlassCard(cornerRadius: 19)
        }
        .buttonStyle(PressScaleStyle())
        .disabled(viewModel.savedWords.count < 4)
    }

    private var searchBar: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(LotusApp.muted)
            TextField("Search words…", text: $searchText)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .tint(LotusApp.cobalt)
                .submitLabel(.search)
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(LotusApp.subtle)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 13)
        .frame(height: 46)
        .lotusGlassCard(cornerRadius: 16, opacity: 0.82, shadow: 0.04)
    }

    private var filterPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    let selected = selectedFilter == option
                    Button {
                        withAnimation(.spring(response: 0.34, dampingFraction: 0.76)) {
                            selectedFilter = option
                        }
                    } label: {
                        Text(option.rawValue)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(selected ? .white : LotusApp.muted)
                            .padding(.horizontal, 13)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(selected ? AnyShapeStyle(LotusApp.aurora) : AnyShapeStyle(Color.white.opacity(0.76))))
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
            .padding(.vertical, 2)
        }
    }

    private var wordList: some View {
        LazyVStack(alignment: .leading, spacing: 9) {
            LotusSectionTitle(
                title: filteredAndSorted.isEmpty ? "No words found" : "\(filteredAndSorted.count) word\(filteredAndSorted.count == 1 ? "" : "s")",
                trailing: selectedSort == .dateAdded ? nil : selectedSort.rawValue
            )

            if filteredAndSorted.isEmpty {
                Text("Try another search or filter")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
            } else {
                ForEach(filteredAndSorted) { word in
                    wordRow(word)
                }
            }
        }
    }

    private func wordRow(_ word: SavedWord) -> some View {
        let level = masteryMap[word.id] ?? .new
        let isDue = viewModel.isDue(word)

        return Button { selectedWord = word } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(level.color)
                    .frame(width: 4, height: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(word.word)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text(word.translation)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
                Spacer()
                Button { TTSService.shared.speak(word.word) } label: {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(LotusApp.cobalt)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(LotusApp.cobalt.opacity(0.08)))
                }
                .buttonStyle(.plain)
                if isDue {
                    Text("Due")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.amber)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(LotusApp.amber.opacity(0.10)))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(LotusApp.subtle)
                }
            }
            .padding(13)
            .lotusGlassCard(cornerRadius: 18, opacity: 0.80, shadow: 0.045)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                HapticService.shared.notify(.error)
                viewModel.removeWord(id: word.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func wordDetailSheet(_ word: SavedWord) -> some View {
        let level = masteryMap[word.id] ?? .new
        let isDue = viewModel.isDue(word)

        return LotusAppScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    Capsule()
                        .fill(LotusApp.subtle.opacity(0.55))
                        .frame(width: 38, height: 4)
                        .padding(.top, 10)

                    VStack(spacing: 7) {
                        HStack(spacing: 10) {
                            Text(word.word)
                                .font(.system(size: 32, weight: .regular, design: .serif))
                                .foregroundStyle(LotusApp.ink)
                            Button { TTSService.shared.speak(word.word) } label: {
                                LotusIconBadge(icon: "speaker.wave.2.fill", color: LotusApp.cobalt, size: 38)
                            }
                            .buttonStyle(PressScaleStyle())
                        }
                        Text(word.translation)
                            .font(.system(size: 17, design: .rounded))
                            .foregroundStyle(LotusApp.muted)
                    }

                    HStack(spacing: 9) {
                        detailCell(icon: level.icon, label: "Mastery", value: level.label, color: level.color)
                        detailCell(icon: "clock.fill", label: "Review", value: isDue ? "Now" : "Later", color: isDue ? LotusApp.amber : LotusApp.cobalt)
                        detailCell(icon: "calendar", label: "Added", value: shortDate(word.addedAt), color: LotusApp.violet)
                    }

                    VStack(spacing: 10) {
                        if isDue {
                            LotusGradientButton(title: "Review this word", icon: "bolt.fill") {
                                if let index = viewModel.savedWords.firstIndex(where: { $0.id == word.id }) {
                                    viewModel.flashcardIndex = index
                                }
                                selectedWord = nil
                            }
                        }
                        Button(role: .destructive) {
                            viewModel.removeWord(id: word.id)
                            selectedWord = nil
                        } label: {
                            Label("Remove word", systemImage: "trash")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(LotusApp.danger)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(RoundedRectangle(cornerRadius: 16).fill(LotusApp.danger.opacity(0.08)))
                        }
                        .buttonStyle(PressScaleStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    private func detailCell(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color)
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundStyle(LotusApp.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 13)
        .lotusGlassCard(cornerRadius: 16)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: date)
    }

    private func startSeedAnimation() {
        guard !reduceMotion else {
            seedIsAlive = true
            return
        }
        seedIsAlive = false
        DispatchQueue.main.async { seedIsAlive = true }
    }
}
