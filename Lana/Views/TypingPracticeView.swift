import SwiftUI

struct TypingPracticeView: View {
    @StateObject private var viewModel = TypingPracticeViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    var body: some View {
        DarkScreen {
            if viewModel.isFinished {
                finishedView
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                quizContent
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isChecked)
        .onAppear { isFocused = true }
    }

    // MARK: Quiz Content

    private var quizContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                progressBar
                if let q = viewModel.current {
                    translationHint(q)
                    sentenceCard(q)
                    inputField
                    if viewModel.isChecked {
                        resultFeedback(q)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        nextButton
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    } else {
                        checkButton
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            VStack(spacing: 2) {
                Text("MINI GAME")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Typing Practice")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Text("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(DarkDS.lime))
        }
        .padding(.top, 16)
    }

    // MARK: Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DarkDS.card2).frame(height: 6)
                Capsule().fill(DarkDS.lime)
                    .frame(width: geo.size.width * viewModel.progress, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: Translation Hint

    private func translationHint(_ q: TypingQuestion) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "translate")
                .font(.system(size: 12))
                .foregroundStyle(DarkDS.muted)
            Text(q.translation)
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(Capsule().fill(DarkDS.card2))
    }

    // MARK: Sentence Card

    private func sentenceCard(_ q: TypingQuestion) -> some View {
        let parts = q.sentence.components(separatedBy: "___")
        let blank: Text = viewModel.isChecked
            ? Text(q.answer)
                .bold()
                .foregroundColor(viewModel.isCorrect
                    ? Color(red: 0.20, green: 0.78, blue: 0.43)
                    : Color(red: 0.98, green: 0.30, blue: 0.30))
                .underline()
            : Text("_____")
                .bold()
                .foregroundColor(DarkDS.lime)
                .underline()

        let full: Text = parts.count >= 2
            ? (Text(parts[0]).foregroundColor(LotusApp.ink) + blank + Text(parts[1]).foregroundColor(LotusApp.ink))
            : Text(q.sentence).foregroundColor(LotusApp.ink)

        return full
            .font(.system(size: 20, weight: .semibold))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 22).fill(DarkDS.card))
    }

    // MARK: Input Field

    private var inputField: some View {
        TextField("Type the missing word...", text: $viewModel.typedText)
            .font(.system(size: 18, design: .rounded))
            .foregroundStyle(LotusApp.ink)
            .tint(DarkDS.lime)
            .multilineTextAlignment(.center)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.done)
            .onSubmit { if !viewModel.isChecked { viewModel.checkAnswer(); isFocused = false } }
            .focused($isFocused)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DarkDS.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(isFocused ? DarkDS.lime.opacity(0.6) : DarkDS.border, lineWidth: 1.5)
                    )
            )
            .disabled(viewModel.isChecked)
    }

    // MARK: Result Feedback

    private func resultFeedback(_ q: TypingQuestion) -> some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(viewModel.isCorrect
                    ? Color(red: 0.20, green: 0.78, blue: 0.43)
                    : Color(red: 0.98, green: 0.30, blue: 0.30))
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                if !viewModel.isCorrect {
                    Text("Answer: \(q.answer)")
                        .font(.system(size: 12))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(viewModel.isCorrect
                      ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.12)
                      : Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12))
        )
    }

    // MARK: Check Button

    private var checkButton: some View {
        let isEmpty = viewModel.typedText.trimmingCharacters(in: .whitespaces).isEmpty
        return Button {
            viewModel.checkAnswer()
            isFocused = false
        } label: {
            Text("Check")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(isEmpty ? DarkDS.muted : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(isEmpty ? DarkDS.card2 : DarkDS.lime))
        }
        .buttonStyle(PressScaleStyle())
        .disabled(isEmpty)
    }

    // MARK: Next Button

    private var nextButton: some View {
        Button { viewModel.next() } label: {
            Text(viewModel.currentIndex + 1 >= viewModel.questions.count ? "Finish" : "Next")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(DarkDS.lime.opacity(0.10)).frame(width: 130, height: 130)
                Circle().fill(DarkDS.lime.opacity(0.20)).frame(width: 90, height: 90)
                Image(systemName: viewModel.score == viewModel.questions.count ? "star.fill" : "bolt.fill")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundStyle(DarkDS.lime)
            }
            Text("\(viewModel.score)/\(viewModel.questions.count)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(viewModel.score == viewModel.questions.count ? "Perfect typing!" : "Keep practicing!")
                .font(.system(size: 16))
                .foregroundStyle(DarkDS.muted)
            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 40)
            Spacer()
        }
        .onAppear {
            appState.awardXPOnce(key: "typing_\(Int(Date().timeIntervalSince1970 / 86_400))", amount: 25)
        }
    }
}
