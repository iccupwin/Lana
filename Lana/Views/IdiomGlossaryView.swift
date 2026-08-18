import SwiftUI

struct IdiomGlossaryView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let idioms: [Idiom]
    @State private var searchText = ""
    @State private var selectedDifficulty: String? = nil
    @State private var expandedId: String? = nil

    init(repository: ContentRepository) {
        idioms = repository.fetchIdioms()
    }

    private var filtered: [Idiom] {
        idioms.filter { idiom in
            let matchSearch = searchText.isEmpty ||
                idiom.phrase.localizedCaseInsensitiveContains(searchText) ||
                idiom.translation.localizedCaseInsensitiveContains(searchText)
            let matchDiff = selectedDifficulty == nil || idiom.difficulty == selectedDifficulty
            return matchSearch && matchDiff
        }
    }

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                pageHeader
                difficultyFilter
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                if filtered.isEmpty {
                    Spacer()
                    Text("No idioms found")
                        .font(.system(size: 15))
                        .foregroundStyle(DarkDS.muted)
                    Spacer()
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(filtered) { idiom in
                                idiomCard(idiom)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expandedId)
    }

    // MARK: Header

    private var pageHeader: some View {
        VStack(spacing: 12) {
            HStack {
                DarkBackButton()
                Spacer()
                VStack(spacing: 2) {
                    Text("Idioms Glossary")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Text("\(filtered.count) expressions")
                        .font(.system(size: 11))
                        .foregroundStyle(DarkDS.muted)
                }
                Spacer()
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)

            // Search bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15))
                    .foregroundStyle(DarkDS.muted)
                TextField("Search idioms...", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundStyle(LotusApp.ink)
                    .tint(DarkDS.lime)
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(DarkDS.muted)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .background(DarkDS.bg)
    }

    // MARK: Difficulty Filter

    private var difficultyFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterPill(label: "All",    value: nil)
                filterPill(label: "Easy",   value: "easy")
                filterPill(label: "Medium", value: "medium")
                filterPill(label: "Hard",   value: "hard")
            }
        }
    }

    private func filterPill(label: String, value: String?) -> some View {
        let isSelected = selectedDifficulty == value
        return Button { selectedDifficulty = value } label: {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isSelected ? .white : LotusApp.muted)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(
                    Capsule().fill(isSelected ? difficultyColor(value) : DarkDS.card2)
                )
                .overlay(Capsule().strokeBorder(isSelected ? Color.clear : DarkDS.border, lineWidth: 1))
        }
        .buttonStyle(PressScaleStyle())
    }

    private func difficultyColor(_ value: String?) -> Color {
        switch value {
        case "easy":   return DarkDS.lime
        case "medium": return Color(red: 0.98, green: 0.79, blue: 0.20)
        case "hard":   return Color(red: 0.98, green: 0.30, blue: 0.30)
        default:       return Color(red: 0.22, green: 0.44, blue: 0.98)
        }
    }

    // MARK: Idiom Card (expandable)

    private func idiomCard(_ idiom: Idiom) -> some View {
        let isExpanded = expandedId == idiom.id
        return Button {
            HapticService.shared.selection()
            withAnimation { expandedId = isExpanded ? nil : idiom.id }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(idiom.phrase)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(LotusApp.ink)
                            .multilineTextAlignment(.leading)
                        Text(idiom.translation)
                            .font(.system(size: 12))
                            .foregroundStyle(DarkDS.muted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 6) {
                        difficultyBadge(idiom.difficulty)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(DarkDS.muted)
                    }
                }

                if isExpanded {
                    Divider().background(DarkDS.border).padding(.vertical, 12)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                                .padding(.top, 2)
                            Text(idiom.meaning)
                                .font(.system(size: 13))
                                .foregroundStyle(LotusApp.ink.opacity(0.88))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "quote.opening")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
                                .padding(.top, 2)
                            Text(idiom.example)
                                .font(.system(size: 13))
                                .foregroundStyle(DarkDS.muted)
                                .italic()
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
            .overlay(
                isExpanded
                    ? RoundedRectangle(cornerRadius: 18).strokeBorder(DarkDS.border, lineWidth: 1)
                    : nil
            )
        }
        .buttonStyle(.plain)
    }

    private func difficultyBadge(_ difficulty: String) -> some View {
        Text(difficulty.capitalized)
            .font(.system(size: 9, weight: .bold, design: .rounded))
            .foregroundStyle(difficultyColor(difficulty))
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().fill(difficultyColor(difficulty).opacity(0.15)))
    }
}
