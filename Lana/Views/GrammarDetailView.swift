import SwiftUI

struct GrammarDetailView: View {
    let topic: GrammarTopic
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @State private var selectedAnswers: [String: Int] = [:]
    @State private var showResults = false

    private var allAnswered: Bool {
        topic.miniQuiz.allSatisfy { selectedAnswers[$0.id] != nil }
    }

    private var score: Int {
        topic.miniQuiz.filter { selectedAnswers[$0.id] == $0.correctIndex }.count
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    pageHeader
                    contentBody
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                DarkBackButton()
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: "textformat.abc")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(alignment: .leading, spacing: 6) {
                Text("GRAMMAR")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text(topic.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
    }

    // MARK: Content

    private var contentBody: some View {
        VStack(spacing: 20) {
            explanationCard
            russianContrastCard
            examplesCard
            if !topic.miniQuiz.isEmpty {
                miniQuizSection
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: Explanation

    private var explanationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                Text("Explanation")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Text(topic.explanation)
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.08)))
    }

    // MARK: Russian Contrast

    @ViewBuilder
    private var russianContrastCard: some View {
        if let contrast = topic.russianContrast {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("RU")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(Capsule().fill(Color(red: 0.85, green: 0.22, blue: 0.22)))
                    Text("Russian Learner Tip")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                }
                Text(contrast)
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.98, green: 0.30, blue: 0.60).opacity(0.08)))
        }
    }

    // MARK: Examples

    private var examplesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "text.quote")
                    .font(.system(size: 14))
                    .foregroundStyle(DarkDS.muted)
                Text("Examples")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            ForEach(topic.examples, id: \.self) { example in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                        .padding(.top, 6)
                    Text(example)
                        .font(.system(size: 13))
                        .foregroundStyle(LotusApp.ink.opacity(0.88))
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    // MARK: Mini Quiz

    private var miniQuizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                Text("Mini Quiz")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }

            ForEach(Array(topic.miniQuiz.enumerated()), id: \.element.id) { i, q in
                miniQuizCard(index: i, question: q)
            }

            if allAnswered && !showResults {
                Button {
                    withAnimation { showResults = true }
                    appState.awardXPOnce(key: "grammar_\(topic.id)", amount: 15)
                } label: {
                    Text("Check Answers")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
                }
                .buttonStyle(PressScaleStyle())
            }

            if showResults {
                let perfect = score == topic.miniQuiz.count
                HStack(spacing: 14) {
                    Image(systemName: perfect ? "star.fill" : "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(perfect ? DarkDS.lime : Color(red: 0.20, green: 0.78, blue: 0.43))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(score) / \(topic.miniQuiz.count) correct")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(LotusApp.ink)
                        Text(perfect ? "Perfect! You've got this rule!" : "Review the explanation and try again.")
                            .font(.system(size: 12))
                            .foregroundStyle(DarkDS.muted)
                    }
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(perfect ? DarkDS.lime.opacity(0.10) : Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.10))
                )
            }
        }
    }

    private func miniQuizCard(index: Int, question: QuizQuestion) -> some View {
        let selected = selectedAnswers[question.id]

        return VStack(alignment: .leading, spacing: 10) {
            Text("Q\(index + 1). \(question.text)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(question.options.indices, id: \.self) { idx in
                Button {
                    if !showResults { selectedAnswers[question.id] = idx }
                } label: {
                    HStack {
                        Text(question.options[idx])
                            .font(.system(size: 13))
                            .foregroundStyle(mquizTextColor(selected: selected, idx: idx, correct: question.correctIndex))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let sel = selected, sel == idx {
                            Image(systemName: showResults
                                  ? (sel == question.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                  : "circle.fill")
                                .foregroundStyle(showResults
                                                 ? (sel == question.correctIndex
                                                    ? Color(red: 0.20, green: 0.78, blue: 0.43)
                                                    : Color(red: 0.98, green: 0.30, blue: 0.30))
                                                 : Color(red: 0.98, green: 0.79, blue: 0.20))
                        }
                    }
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(mquizBgColor(selected: selected, idx: idx, correct: question.correctIndex)))
                }
                .buttonStyle(.plain)
                .disabled(showResults)
            }

            if showResults, let sel = selected {
                if sel != question.correctIndex {
                    Text("Correct: \(question.options[question.correctIndex])")
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                }
                Text(question.explanation)
                    .font(.system(size: 11))
                    .foregroundStyle(DarkDS.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    private func mquizBgColor(selected: Int?, idx: Int, correct: Int) -> Color {
        guard let sel = selected, showResults else {
            return selected == idx
                ? Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15)
                : DarkDS.card2
        }
        if idx == correct { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15) }
        if sel == idx { return Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12) }
        return DarkDS.card2
    }

    private func mquizTextColor(selected: Int?, idx: Int, correct: Int) -> Color {
        guard let sel = selected, showResults else { return LotusApp.ink }
        if idx == correct { return Color(red: 0.20, green: 0.78, blue: 0.43) }
        if sel == idx { return Color(red: 0.98, green: 0.30, blue: 0.30) }
        return DarkDS.muted
    }
}
