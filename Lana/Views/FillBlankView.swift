import SwiftUI

struct FillBlankView: View {
    @StateObject private var viewModel = FillBlankViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DarkScreen {
            if viewModel.isFinished {
                finishedScreen
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                VStack(spacing: 0) {
                    pageHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 56)
                        .padding(.bottom, 16)

                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            if let q = viewModel.current {
                                sentenceCard(q)
                                optionsGrid(q)
                                if viewModel.isAnswered {
                                    nextButton
                                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isAnswered)
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack {
            DarkBackButton()

            Spacer()

            VStack(spacing: 2) {
                Text("MINI GAME")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Fill the Blank")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }

            Spacer()

            Text("\(viewModel.score)/\(viewModel.questions.count)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.5)))
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DarkDS.card2)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.62, green: 0.38, blue: 0.98))
                    .frame(width: geo.size.width * viewModel.progress, height: 6)
                    .animation(.spring(response: 0.4), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Sentence Card

    private func sentenceCard(_ q: FillBlankQuestion) -> some View {
        VStack(spacing: 14) {
            sentenceText(q.sentence)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(q.translation)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DarkDS.card)
        )
    }

    /// Renders sentence with "___" shown as a styled underline placeholder
    private func sentenceText(_ sentence: String) -> some View {
        let parts = sentence.components(separatedBy: "___")
        guard parts.count == 2 else {
            return AnyView(Text(sentence))
        }
        let answered = viewModel.isAnswered
        let answer = viewModel.selectedOption ?? "___"
        let isCorrect = answered && answer == viewModel.current?.answer

        let placeholder = answered
            ? Text(answer)
                .foregroundColor(isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color.red)
                .bold()
                .underline()
            : Text("___")
                .foregroundColor(Color(red: 0.62, green: 0.38, blue: 0.98))
                .bold()
                .underline()

        let result = Text(parts[0]) + placeholder + Text(parts[1])
        return AnyView(result)
    }

    // MARK: - Options Grid

    private func optionsGrid(_ q: FillBlankQuestion) -> some View {
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(q.options, id: \.self) { option in
                optionButton(option: option, q: q)
            }
        }
    }

    private func optionButton(option: String, q: FillBlankQuestion) -> some View {
        let answered = viewModel.isAnswered
        let selected = viewModel.selectedOption == option
        let isCorrectOption = option == q.answer
        let isWrongSelected = answered && selected && !isCorrectOption

        let bgColor: Color = {
            guard answered else { return DarkDS.card }
            if isCorrectOption { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.4) }
            if isWrongSelected { return Color.red.opacity(0.15) }
            return DarkDS.card
        }()

        let iconName: String? = {
            guard answered else { return nil }
            if isCorrectOption { return "checkmark.circle.fill" }
            if isWrongSelected { return "xmark.circle.fill" }
            return nil
        }()

        let iconColor: Color = isCorrectOption ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color.red

        return Button {
            viewModel.select(option)
        } label: {
            HStack(spacing: 8) {
                Text(option)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                if let icon = iconName {
                    Image(systemName: icon)
                        .font(.system(size: 15))
                        .foregroundStyle(iconColor)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        answered && isCorrectOption
                            ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.4)
                            : answered && isWrongSelected ? Color.red.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(PressScaleStyle())
        .disabled(answered)
    }

    // MARK: - Next Button

    private var nextButton: some View {
        Button {
            viewModel.next()
        } label: {
            HStack(spacing: 8) {
                Text(viewModel.currentIndex + 1 >= viewModel.questions.count ? "See Results" : "Next")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Image(systemName: viewModel.currentIndex + 1 >= viewModel.questions.count ? "checkmark.circle.fill" : "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(DarkDS.lime)
            )
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: - Finished Screen

    private var finishedScreen: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.25))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.5))
                    .frame(width: 100, height: 100)
                Image(systemName: scoreEmoji)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
            }

            VStack(spacing: 10) {
                Text("Complete!")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text("\(viewModel.score) out of \(viewModel.questions.count) correct")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }

            HStack(spacing: 20) {
                finishedStat(label: "Score", value: "\(viewModel.score)/\(viewModel.questions.count)")
                finishedStat(label: "Accuracy", value: viewModel.questions.isEmpty ? "—" : "\(Int(Double(viewModel.score) / Double(viewModel.questions.count) * 100))%")
            }
            .padding(.horizontal, 24)

            Text("+20 XP")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Capsule().fill(DarkDS.lime))

            Button {
                appState.awardXPOnce(key: "fill_blank_\(Int(Date().timeIntervalSince1970 / 86400))", amount: 20)
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(DarkDS.lime)
                    )
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 24)

            Spacer()
        }
        .onAppear {
            appState.awardXPOnce(key: "fill_blank_\(Int(Date().timeIntervalSince1970 / 86400))", amount: 20)
        }
    }

    private func finishedStat(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.3))
        )
    }

    private var scoreEmoji: String {
        let total = viewModel.questions.count
        guard total > 0 else { return "hand.thumbsup.fill" }
        let ratio = Double(viewModel.score) / Double(total)
        switch ratio {
        case 0.9...: return "trophy.fill"
        case 0.7...: return "star.fill"
        case 0.5...: return "hand.thumbsup.fill"
        default:     return "figure.strengthtraining.traditional"
        }
    }
}
