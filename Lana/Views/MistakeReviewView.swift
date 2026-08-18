import SwiftUI

struct MistakeReviewView: View {
    @ObservedObject var viewModel: MistakeReviewViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DarkScreen {
            if viewModel.reviewItems.isEmpty {
                emptyState
            } else if viewModel.isFinished {
                finishedView
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                quizContent
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.isAnswered)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.3))
                    .frame(width: 120, height: 120)
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(DarkDS.muted)
            }
            Text("No mistakes yet!")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundStyle(LotusApp.ink)
            Text("Keep practicing and your wrong answers\nwill appear here for review.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
            Button { dismiss() } label: {
                Text("Back to Practice")
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
        .padding(.horizontal, 20)
    }

    // MARK: - Quiz Content

    private var quizContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                progressBar

                if let item = viewModel.current {
                    sourceTag(item)
                    questionCard(item)
                    optionsGrid(item)
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

    // MARK: - Header

    private var header: some View {
        HStack {
            DarkBackButton()

            Spacer()

            VStack(spacing: 2) {
                Text("REVIEW")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Mistake Review")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }

            Spacer()

            Text("\(viewModel.currentIndex + 1)/\(viewModel.total)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.5)))
        }
        .padding(.top, 60)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DarkDS.card2)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.98, green: 0.55, blue: 0.20))
                    .frame(
                        width: geo.size.width * (viewModel.total > 0
                            ? Double(viewModel.currentIndex) / Double(viewModel.total)
                            : 0),
                        height: 6
                    )
                    .animation(.spring(response: 0.4), value: viewModel.currentIndex)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Source Tag

    private func sourceTag(_ item: MistakeItem) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 11))
                .foregroundStyle(DarkDS.muted)
            Text("Wrong in: \(item.source)")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(DarkDS.card2.opacity(0.7)))
    }

    // MARK: - Question Card

    private func questionCard(_ item: MistakeItem) -> some View {
        let parts = item.questionText.components(separatedBy: "___")
        let blank: Text = viewModel.isAnswered
            ? Text(item.correctAnswer)
                .bold()
                .foregroundColor(Color(red: 0.20, green: 0.78, blue: 0.43))
                .underline()
            : Text("_____")
                .bold()
                .foregroundColor(Color(red: 0.98, green: 0.55, blue: 0.20))
                .underline()

        let composed: Text = parts.count >= 2
            ? (Text(parts[0]) + blank + Text(parts[1]))
            : Text(item.questionText)

        return composed
            .font(.system(size: 20, weight: .medium, design: .serif))
            .foregroundStyle(LotusApp.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(DarkDS.card)
            )
    }

    // MARK: - Options Grid

    private func optionsGrid(_ item: MistakeItem) -> some View {
        let options = viewModel.buildOptions(for: item)
        let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        return LazyVGrid(columns: cols, spacing: 12) {
            ForEach(options, id: \.self) { option in
                optionButton(option: option, item: item)
            }
        }
    }

    private func optionButton(option: String, item: MistakeItem) -> some View {
        let answered = viewModel.isAnswered
        let selected = viewModel.selectedOption == option
        let isCorrectOption = option == item.correctAnswer
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

        let iconColor: Color = isCorrectOption
            ? Color(red: 0.20, green: 0.78, blue: 0.43)
            : Color.red

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
                            : (answered && isWrongSelected ? Color.red.opacity(0.3) : Color.clear),
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
                Text(viewModel.currentIndex + 1 >= viewModel.total ? "See Results" : "Next")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Image(systemName: viewModel.currentIndex + 1 >= viewModel.total
                      ? "checkmark.circle.fill"
                      : "arrow.right")
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

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.25))
                    .frame(width: 140, height: 140)
                Circle()
                    .fill(Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.5))
                    .frame(width: 100, height: 100)
                Image(systemName: scoreEmoji)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(red: 0.98, green: 0.55, blue: 0.20))
            }

            VStack(spacing: 10) {
                Text("Review Complete!")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text("\(viewModel.correctCount) out of \(viewModel.total) correct")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }

            HStack(spacing: 20) {
                scoreStatCard(label: "Correct", value: "\(viewModel.correctCount)")
                scoreStatCard(label: "Total", value: "\(viewModel.total)")
            }
            .padding(.horizontal, 24)

            Button {
                viewModel.loadMistakes()
                appState.sqliteService.clearAllMistakes()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                    Text("Clear All Mistakes")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundStyle(Color.red.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.red.opacity(0.08))
                )
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 24)

            Button { dismiss() } label: {
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
    }

    private func scoreStatCard(label: String, value: String) -> some View {
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
                .fill(Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.3))
        )
    }

    private var scoreEmoji: String {
        guard viewModel.total > 0 else { return "hand.thumbsup.fill" }
        let ratio = Double(viewModel.correctCount) / Double(viewModel.total)
        switch ratio {
        case 0.9...: return "trophy.fill"
        case 0.7...: return "star.fill"
        case 0.5...: return "hand.thumbsup.fill"
        default:     return "figure.strengthtraining.traditional"
        }
    }
}
