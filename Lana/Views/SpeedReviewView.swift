import SwiftUI

struct SpeedReviewView: View {
    @StateObject private var viewModel: SpeedReviewViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init(sqliteService: SQLiteService) {
        _viewModel = StateObject(wrappedValue: SpeedReviewViewModel(sqliteService: sqliteService))
    }

    var body: some View {
        DarkScreen {
            if !viewModel.canStart {
                emptyView
            } else if viewModel.isFinished {
                finishedView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else if let card = viewModel.currentCard {
                gameView(card: card)
            } else {
                emptyView
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
        .onDisappear {
            appState.awardXPOnce(key: "speed_review_\(Int(Date().timeIntervalSince1970 / 86_400))", amount: 15)
        }
    }

    // MARK: Game View

    private func gameView(card: SavedWord) -> some View {
        VStack(spacing: 0) {
            gameHeader
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

            timerBar
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

            wordCard(card)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            choicesGrid
                .padding(.horizontal, 20)

            Spacer()
        }
    }

    private var gameHeader: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(DarkDS.card))
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.orange)
                Text("\(viewModel.score) pts")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Text("\(viewModel.round)/10")
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
        }
    }

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DarkDS.card2.opacity(0.5))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(timerColor)
                    .frame(width: geo.size.width * CGFloat(viewModel.timeRemaining / 10.0), height: 6)
                    .animation(.linear(duration: 0.1), value: viewModel.timeRemaining)
            }
        }
        .frame(height: 6)
    }

    private var timerColor: Color {
        if viewModel.timeRemaining > 6 { return Color(red: 0.20, green: 0.78, blue: 0.43) }
        if viewModel.timeRemaining > 3 { return Color(red: 0.98, green: 0.79, blue: 0.20) }
        return .red
    }

    private func wordCard(_ card: SavedWord) -> some View {
        VStack(spacing: 8) {
            if let result = viewModel.isCorrect {
                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(result ? Color(red: 0.20, green: 0.78, blue: 0.43) : .red)
                    .transition(.scale.combined(with: .opacity))
            }
            Text(card.word)
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(DarkDS.card)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.isCorrect)
    }

    private var choicesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(viewModel.choices.indices, id: \.self) { i in
                choiceButton(index: i)
            }
        }
    }

    private func choiceButton(index: Int) -> some View {
        let selected = viewModel.selectedIndex == index
        let correct = viewModel.isCorrect != nil && viewModel.choices[index] == viewModel.currentCard?.translation
        let wrong = selected && viewModel.isCorrect == false

        return Button {
            HapticService.shared.selection()
            viewModel.select(index: index)
        } label: {
            Text(viewModel.choices[index])
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(correct ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.4) :
                              wrong ? Color.red.opacity(0.2) :
                              selected ? Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.4) :
                              DarkDS.card)
                )
        }
        .buttonStyle(PressScaleStyle())
        .disabled(viewModel.selectedIndex != nil)
    }

    // MARK: Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: scoreEmoji)
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            Text("Round Complete!")
                .font(.system(size: 26, weight: .bold, design: .serif))
                .foregroundStyle(LotusApp.ink)
            Text("\(viewModel.score) / 10 correct")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
            Text("+15 XP earned")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(Capsule().fill(DarkDS.lime))
            Spacer()
            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 40)
            .padding(.bottom, FloatingTabBarMetrics.clearance + 16)
        }
    }

    private var scoreEmoji: String {
        switch viewModel.score {
        case 9...10: return "trophy.fill"
        case 7...8:  return "star.fill"
        case 5...6:  return "hand.thumbsup.fill"
        default:     return "figure.strengthtraining.traditional"
        }
    }

    // MARK: Empty

    private var emptyView: some View {
        VStack(spacing: 18) {
            Image("LotusSavedSeed")
                .resizable()
                .scaledToFit()
                .frame(height: 176)
                .accessibilityHidden(true)
            Text("Save at least 4 words\nto start Speed Review")
                .font(.system(size: 25, weight: .regular, design: .serif))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
            Text("Your saved vocabulary becomes a fast recall workout.")
                .font(.system(size: 12, design: .rounded))
                .foregroundStyle(LotusApp.muted)
                .multilineTextAlignment(.center)
            Button { dismiss() } label: {
                Text("Back to Practice")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(RoundedRectangle(cornerRadius: 17).fill(LotusApp.aurora))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 32)
        }
    }
}
