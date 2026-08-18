import SwiftUI

struct GrammarView: View {
    @ObservedObject var viewModel: GrammarViewModel
    private let accentColors: [Color] = [
        LotusApp.cobalt, LotusApp.mint, LotusApp.violet, LotusApp.amber,
        LotusApp.coral, LotusApp.aqua, LotusApp.cobalt, LotusApp.mint,
    ]

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    pageHeader
                    LotusCollectionHero(
                        imageName: "LotusLanguageBook",
                        title: "See the pattern",
                        subtitle: "Clear rules become petals you can reuse",
                        height: 178
                    )
                    LotusSectionTitle(title: "Grammar library", trailing: "\(viewModel.topics.count) topics")
                    topicList
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var pageHeader: some View {
        LotusDetailHeader(
            title: "Grammar",
            subtitle: "Patterns for confident English",
            icon: "textformat.abc",
            color: LotusApp.cobalt
        )
    }

    // MARK: List

    private var topicList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(viewModel.topics.enumerated()), id: \.element.id) { i, topic in
                NavigationLink {
                    GrammarDetailView(topic: topic)
                } label: {
                    topicRow(topic: topic, index: i)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func topicRow(topic: GrammarTopic, index: Int) -> some View {
        let color = accentColors[index % accentColors.count]
        return HStack(spacing: 14) {
            LotusIconBadge(icon: "textformat", color: color, size: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(topic.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(topic.explanation.prefix(55) + "…")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    LotusStatusPill(text: "\(topic.examples.count) examples", color: LotusApp.muted, icon: "text.quote")
                    LotusStatusPill(text: "\(topic.miniQuiz.count) quiz", color: color, icon: "checkmark.circle")
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LotusApp.subtle)
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }
}
