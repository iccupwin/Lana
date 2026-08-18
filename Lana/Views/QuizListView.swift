import SwiftUI

struct QuizListView: View {
    @EnvironmentObject private var appState: AppState
    private var quizzes: [Quiz] {
        appState.contentRepository.fetchQuizzes()
    }

    private let levelLabels = ["A1", "A1-A2", "A2", "A2-B1", "B1", "B1-B2", "B2", "B2-C1"]
    private let accentColors: [Color] = [
        LotusApp.cobalt, LotusApp.mint, LotusApp.violet, LotusApp.coral,
        LotusApp.amber, LotusApp.aqua, LotusApp.violet, LotusApp.cobalt,
    ]

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 16) {
                    pageHeader
                    LotusCollectionHero(
                        imageName: "LotusQuizConstellation",
                        title: "Choose the next petal",
                        subtitle: "Every quiz opens another part of your English",
                        height: 206
                    )
                    LotusSectionTitle(title: "Quiz collection", trailing: "\(quizzes.count) available")
                    quizList
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var pageHeader: some View {
        LotusDetailHeader(
            title: "Quizzes",
            subtitle: "Short focused challenges",
            icon: "checkmark.seal.fill",
            color: LotusApp.violet
        )
    }

    // MARK: List

    private var quizList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(quizzes.enumerated()), id: \.element.id) { i, quiz in
                NavigationLink {
                    QuizView(viewModel: QuizViewModel(
                        repository: appState.contentRepository,
                        sqliteService: appState.sqliteService,
                        quizId: quiz.id
                    ))
                } label: {
                    quizCard(quiz: quiz, index: i)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func quizCard(quiz: Quiz, index: Int) -> some View {
        let color = accentColors[index % accentColors.count]
        let level = index < levelLabels.count ? levelLabels[index] : "B1"

        return HStack(spacing: 14) {
            LotusIconBadge(icon: "sparkles", color: color, size: 46)

            VStack(alignment: .leading, spacing: 6) {
                Text(quiz.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(quiz.description)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
                    .lineLimit(2)
                HStack(spacing: 8) {
                    LotusStatusPill(text: "\(quiz.questions.count) questions", color: LotusApp.muted, icon: "circle.grid.2x2.fill")
                    LotusStatusPill(text: level, color: color)
                }
                .padding(.top, 2)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(color.opacity(0.09))
                    .frame(width: 44, height: 44)
                Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(color)
            }
        }
        .padding(14)
        .lotusGlassCard(cornerRadius: 19, opacity: 0.80, shadow: 0.045)
    }
}
