import SwiftUI

struct StoryReaderView: View {
    @ObservedObject var viewModel: StoryReaderViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DarkDS.bg.ignoresSafeArea()

            if viewModel.showQuiz {
                quizView
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                readerView
            }

            if let word = viewModel.selectedWord {
                wordPopup(word)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showQuiz)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedWord?.word)
    }

    // MARK: Reader

    private var readerView: some View {
        VStack(spacing: 0) {
            readerHeader
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    paragraphProgress
                    paragraphText
                    navigationButtons
                }
                .padding(20)
                .padding(.bottom, 110)
            }
        }
    }

    private var readerHeader: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(DarkDS.card))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.story.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text("Paragraph \(viewModel.currentParagraphIndex + 1) of \(viewModel.story.paragraphs.count)")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
            Text(viewModel.story.cefrLevel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(Color(hex: viewModel.story.colorHex)))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 16)
        .background(DarkDS.bg.opacity(0.97))
    }

    private var paragraphProgress: some View {
        HStack(spacing: 4) {
            ForEach(0..<viewModel.story.paragraphs.count, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3)
                    .fill(i <= viewModel.currentParagraphIndex ? Color(hex: viewModel.story.colorHex) : DarkDS.card2)
                    .frame(height: 4)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentParagraphIndex)
            }
        }
    }

    private var paragraphText: some View {
        let paragraph = viewModel.currentParagraph
        let words = paragraph.highlightedWords.map { $0.word }

        return VStack(alignment: .leading, spacing: 0) {
            HighlightedTextView(
                text: paragraph.text,
                highlightedWords: words,
                highlightColor: Color(hex: viewModel.story.colorHex).opacity(0.5),
                onTapWord: { word in
                    let hw = paragraph.highlightedWords.first { $0.word == word }
                    withAnimation { viewModel.selectedWord = hw }
                }
            )
            .font(.system(size: 18, weight: .regular, design: .serif))
            .foregroundStyle(LotusApp.ink)
            .lineSpacing(6)
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if viewModel.currentParagraphIndex > 0 {
                Button {
                    withAnimation { viewModel.currentParagraphIndex -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(DarkDS.card))
                }
                .buttonStyle(PressScaleStyle())
            }

            Spacer()

            Button {
                withAnimation { viewModel.nextParagraph() }
            } label: {
                HStack(spacing: 8) {
                    Text(viewModel.isLastParagraph ? "Take Quiz" : "Next")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                    Image(systemName: viewModel.isLastParagraph ? "checkmark.circle.fill" : "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Capsule().fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
        }
    }

    // MARK: Word Popup

    private func wordPopup(_ word: HighlightedWord) -> some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(word.word)
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(LotusApp.ink)
                    Spacer()
                    Button { withAnimation { viewModel.selectedWord = nil } } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(DarkDS.muted)
                    }
                }
                Text(word.definition)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(word.translation)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(DarkDS.card)
                    .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(DarkDS.border, lineWidth: 1))
            )
            .padding(.bottom, FloatingTabBarMetrics.clearance + 8)
        }
        .ignoresSafeArea(edges: .bottom)
        .onTapGesture { withAnimation { viewModel.selectedWord = nil } }
    }

    // MARK: Quiz

    private var quizView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                quizHeader
                ForEach(viewModel.story.questions.indices, id: \.self) { qi in
                    questionCard(index: qi)
                }
                if !viewModel.quizSubmitted {
                    submitButton
                } else {
                    resultCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }

    private var quizHeader: some View {
        HStack {
            Button { withAnimation { viewModel.showQuiz = false } } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(DarkDS.card))
            }
            Spacer()
            Text("Comprehension Quiz")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.top, 60)
    }

    private func questionCard(index: Int) -> some View {
        let q = viewModel.story.questions[index]
        return VStack(alignment: .leading, spacing: 14) {
            Text("Q\(index + 1). \(q.question)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.ink)

            ForEach(q.options.indices, id: \.self) { oi in
                let selected = viewModel.quizAnswers[index] == oi
                let isCorrect = viewModel.quizSubmitted && oi == q.correctIndex
                let isWrong = viewModel.quizSubmitted && selected && oi != q.correctIndex

                Button { viewModel.selectAnswer(oi, for: index) } label: {
                    HStack {
                        Text(q.options[oi])
                            .font(.system(size: 14, design: .rounded))
                            .foregroundStyle(LotusApp.ink)
                        Spacer()
                        if isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                        } else if isWrong {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(red: 0.98, green: 0.30, blue: 0.30))
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15) :
                                  isWrong   ? Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12) :
                                  selected  ? Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.18) :
                                  DarkDS.card2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(selected ? Color.white.opacity(0.15) : Color.clear, lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(PressScaleStyle())
                .disabled(viewModel.quizSubmitted)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    private var submitButton: some View {
        let allAnswered = viewModel.quizAnswers.allSatisfy { $0 != nil }
        return Button {
            viewModel.submitQuiz(appState: appState)
        } label: {
            Text("Submit Answers")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(allAnswered ? .black : DarkDS.muted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(allAnswered ? DarkDS.lime : DarkDS.card2)
                )
        }
        .buttonStyle(PressScaleStyle())
        .disabled(!allAnswered)
    }

    private var resultCard: some View {
        let total = viewModel.story.questions.count
        let correct = viewModel.correctCount
        let perfect = correct == total
        return VStack(spacing: 12) {
            Image(systemName: perfect ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(perfect ? DarkDS.lime : Color(red: 0.20, green: 0.78, blue: 0.43))
            Text(perfect ? "Perfect!" : "\(correct)/\(total) correct")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(viewModel.isCompleted ? "+40 XP earned!" : "Keep reading to earn XP")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(DarkDS.muted)
            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }
}

// MARK: - Highlighted Text

struct HighlightedTextView: View {
    let text: String
    let highlightedWords: [String]
    let highlightColor: Color
    let onTapWord: (String) -> Void

    var body: some View {
        buildText()
    }

    private func buildText() -> Text {
        var result = Text("")
        let words = text.components(separatedBy: " ")
        for (i, word) in words.enumerated() {
            let clean = word.trimmingCharacters(in: .punctuationCharacters)
            let isHighlighted = highlightedWords.contains { hw in
                clean.caseInsensitiveCompare(hw) == .orderedSame ||
                clean.caseInsensitiveCompare(hw.components(separatedBy: " ").first ?? "") == .orderedSame
            }
            if isHighlighted {
                result = result + Text(word)
                    .foregroundColor(LotusApp.ink)
                    .underline(true, color: highlightColor)
                    .bold()
            } else {
                result = result + Text(word)
            }
            if i < words.count - 1 { result = result + Text(" ") }
        }
        return result
    }
}
