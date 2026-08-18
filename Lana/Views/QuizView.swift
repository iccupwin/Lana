import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    @State private var showXPFloat: Bool = false
    @State private var xpFloatOffset: CGFloat = 0

    /// When set, called on completion instead of showing inline QuizResultView.
    /// Parameters: (correctCount, totalCount)
    var onStageComplete: ((Int, Int) -> Void)? = nil

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                navBar
                progressLine

                if viewModel.isCompleted, let quiz = viewModel.currentQuiz {
                    if onStageComplete == nil {
                        // Classic free-play result screen
                        ScrollView(.vertical, showsIndicators: false) {
                            QuizResultView(
                                correctCount: viewModel.correctCount,
                                totalCount: quiz.questions.count,
                                questionResults: viewModel.questionResults
                            ) {
                                viewModel.restart()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                            .padding(.bottom, FloatingTabBarMetrics.clearance + 24)
                        }
                    }
                    // Game-mode: onStageComplete fires in onChange below
                } else {
                    quizContent
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.correctCount) { _, _ in
            triggerXPFloat()
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            guard completed, let quiz = viewModel.currentQuiz else { return }
            if let handler = onStageComplete {
                // XP is awarded by QuizMapViewModel
                HapticService.shared.notify(.success)
                handler(viewModel.correctCount, quiz.questions.count)
            } else {
                // Legacy free-play: award XP here
                let isPerfect = viewModel.correctCount == quiz.questions.count
                appState.awardXP(isPerfect ? 45 : 30)
                if isPerfect {
                    showConfetti = true
                    HapticService.shared.notify(.success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { showConfetti = false }
                } else {
                    HapticService.shared.notify(.success)
                }
            }
        }
        .overlay {
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(DarkDS.card2)
                        .frame(width: 38, height: 38)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
            }
            Spacer()
            Text("Review Tests")
                .font(.system(size: 21, weight: .regular, design: .serif))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.78))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
        .shadow(color: LotusApp.ink.opacity(0.045), radius: 12, y: 5)
    }

    // MARK: Progress Line

    private var progressLine: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(DarkDS.card2)
                Rectangle()
                    .fill(LotusApp.aurora)
                    .frame(width: geo.size.width * viewModel.progress)
                    .animation(.linear(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 3)
    }

    // MARK: Quiz Content

    private var quizContent: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    if let question = viewModel.currentQuestion {
                        VStack(alignment: .leading, spacing: 18) {
                            Image("LotusQuizConstellation")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 96)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Choose the correct item")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(DarkDS.muted)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Capsule().fill(DarkDS.card2))
                                Text(question.text)
                                    .font(.system(size: 20, weight: .regular, design: .serif))
                                    .foregroundStyle(LotusApp.ink)
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 20)

                            VStack(spacing: 12) {
                                ForEach(question.options.indices, id: \.self) { idx in
                                    optionButton(question: question, index: idx)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }

                if viewModel.showExplanation, let question = viewModel.currentQuestion {
                    bottomBar(question: question)
                }
            }

            floatingXPBadge
                .allowsHitTesting(false)
        }
    }

    // MARK: Option Button

    private func optionButton(question: QuizQuestion, index: Int) -> some View {
        let answered   = viewModel.showExplanation
        let isCorrect  = index == question.correctIndex
        let isSelected = viewModel.selectedIndex == index

        return Button {
            HapticService.shared.selection()
            viewModel.selectAnswer(index)
        } label: {
            HStack(spacing: 12) {
                // Letter badge
                ZStack {
                    Circle()
                        .fill(optionBadgeBg(answered: answered, isCorrect: isCorrect, isSelected: isSelected))
                        .frame(width: 32, height: 32)
                    Text(["A","B","C","D"][index])
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(optionBadgeFg(answered: answered, isCorrect: isCorrect, isSelected: isSelected))
                }

                Text(question.options[index])
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(answerTextColor(answered: answered, isCorrect: isCorrect, isSelected: isSelected))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if answered && isCorrect {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                } else if answered && isSelected && !isCorrect {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(red: 0.98, green: 0.30, blue: 0.30))
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(answerBgColor(answered: answered, isCorrect: isCorrect, isSelected: isSelected))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(answerBorderColor(answered: answered, isCorrect: isCorrect, isSelected: isSelected), lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.selectedIndex != nil)
    }

    // MARK: Bottom Bar

    private func bottomBar(question: QuizQuestion) -> some View {
        let isCorrect = viewModel.selectedIndex == question.correctIndex
        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(isCorrect
                        ? Color(red: 0.20, green: 0.78, blue: 0.43)
                        : Color(red: 0.98, green: 0.30, blue: 0.30))
                VStack(alignment: .leading, spacing: 2) {
                    Text(isCorrect ? "Correct!" : "Incorrect")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isCorrect
                            ? Color(red: 0.20, green: 0.78, blue: 0.43)
                            : Color(red: 0.98, green: 0.30, blue: 0.30))
                    if !isCorrect {
                        Text("Correct: \(question.options[question.correctIndex])")
                            .font(.system(size: 12))
                            .foregroundStyle(DarkDS.muted)
                    }
                }
                Spacer()
            }

            Button {
                HapticService.shared.impact(.light)
                viewModel.nextQuestion()
            } label: {
                HStack {
                    Text("Continue")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(RoundedRectangle(cornerRadius: 17).fill(LotusApp.aurora))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, FloatingTabBarMetrics.clearance + 10)
        .background(
            Color.white.opacity(0.90)
                .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .top)
        )
    }

    // MARK: Color Helpers

    private func answerBgColor(answered: Bool, isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return DarkDS.card }
        if isCorrect  { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.12) }
        if isSelected { return Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12) }
        return DarkDS.card
    }

    private func answerBorderColor(answered: Bool, isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return DarkDS.border }
        if isCorrect  { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.6) }
        if isSelected { return Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.6) }
        return DarkDS.border
    }

    private func answerTextColor(answered: Bool, isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return LotusApp.ink }
        if isSelected && !isCorrect { return Color(red: 0.98, green: 0.30, blue: 0.30) }
        return LotusApp.ink
    }

    private func optionBadgeBg(answered: Bool, isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return DarkDS.card2 }
        if isCorrect  { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.25) }
        if isSelected { return Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.25) }
        return DarkDS.card2
    }

    private func optionBadgeFg(answered: Bool, isCorrect: Bool, isSelected: Bool) -> Color {
        guard answered else { return DarkDS.muted }
        if isCorrect  { return Color(red: 0.20, green: 0.78, blue: 0.43) }
        if isSelected { return Color(red: 0.98, green: 0.30, blue: 0.30) }
        return DarkDS.muted
    }

    // MARK: - Floating XP Badge

    private var floatingXPBadge: some View {
        Text("+10 XP")
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(DarkDS.lime)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(DarkDS.lime.opacity(0.2))
                    .overlay(Capsule().strokeBorder(DarkDS.lime.opacity(0.4), lineWidth: 1))
            )
            .offset(y: xpFloatOffset)
            .opacity(showXPFloat ? 1 : 0)
            .scaleEffect(showXPFloat ? 1.0 : 0.7)
    }

    private func triggerXPFloat() {
        xpFloatOffset = 0
        showXPFloat = true
        withAnimation(.easeOut(duration: 0.8)) {
            xpFloatOffset = -80
        }
        withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
            showXPFloat = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            xpFloatOffset = 0
        }
    }
}
