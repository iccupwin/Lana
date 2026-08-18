import SwiftUI

struct WordScrambleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: WordScrambleViewModel

    @State private var shakeOffset: CGFloat = 0
    @State private var correctFlash = false

    init(sqliteService: SQLiteService) {
        _viewModel = StateObject(wrappedValue: WordScrambleViewModel(sqliteService: sqliteService))
    }

    var body: some View {
        DarkScreen {
            if !viewModel.hasWords {
                emptyState
            } else if viewModel.isFinished {
                finishedScreen
            } else {
                VStack(spacing: 0) {
                    header
                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            translationHint
                            answerRow
                            underscoreRow
                            lettersGrid
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: viewModel.isCorrect) { correct in
            if let correct = correct {
                if correct {
                    HapticService.shared.notify(.success)
                    withAnimation(.easeInOut(duration: 0.2)) { correctFlash = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation { correctFlash = false }
                    }
                } else {
                    triggerShake()
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            HStack {
                DarkBackButton()
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)

            Spacer()

            Image("LotusSavedSeed")
                .resizable()
                .scaledToFit()
                .frame(height: 176)
                .accessibilityHidden(true)

            Text("Save a few words first")
                .font(.system(size: 27, weight: .regular, design: .serif))
                .foregroundStyle(LotusApp.ink)

            Text("Word Scramble grows from your personal vocabulary.")
                .font(.system(size: 13, design: .rounded))
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

            Spacer()
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
                Text("Word Scramble")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Text("\(viewModel.score)/\(viewModel.round)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(DarkDS.lime))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DarkDS.card2).frame(height: 6)
                Capsule().fill(DarkDS.lime)
                    .frame(width: geo.size.width * viewModel.progress, height: 6)
                    .animation(.spring(response: 0.4), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: Translation Hint

    private var translationHint: some View {
        VStack(spacing: 6) {
            Text("TRANSLATE THIS WORD")
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .tracking(1.4)
            Text(viewModel.currentWord?.translation ?? "—")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: DarkDS.r)
                .fill(correctFlash
                      ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.18)
                      : DarkDS.card)
                .animation(.easeInOut(duration: 0.2), value: correctFlash)
        )
        .overlay(
            correctFlash
                ? RoundedRectangle(cornerRadius: DarkDS.r)
                    .strokeBorder(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.6), lineWidth: 1.5)
                : nil
        )
    }

    // MARK: Answer Row

    private var answerRow: some View {
        VStack(spacing: 8) {
            Text("Your answer")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DarkDS.muted)
            HStack(spacing: 6) {
                if viewModel.userAnswer.isEmpty {
                    Text("Tap letters below")
                        .font(.system(size: 14))
                        .foregroundStyle(DarkDS.muted.opacity(0.5))
                        .frame(height: 44)
                } else {
                    ForEach(Array(viewModel.userAnswer.enumerated()), id: \.offset) { idx, letter in
                        Button { viewModel.removeLetter(at: idx) } label: {
                            Text(letter.uppercased())
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(answerTileFg)
                                .frame(width: 40, height: 44)
                                .background(RoundedRectangle(cornerRadius: 10).fill(answerTileBg))
                        }
                        .buttonStyle(PressScaleStyle())
                        .disabled(viewModel.isCorrect != nil)
                    }
                }
                Spacer()
            }
            .offset(x: shakeOffset)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    private var answerTileBg: Color {
        if let correct = viewModel.isCorrect {
            return correct
                ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.25)
                : Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.25)
        }
        return DarkDS.lime.opacity(0.20)
    }

    private var answerTileFg: Color {
        if let correct = viewModel.isCorrect {
            return correct
                ? Color(red: 0.20, green: 0.78, blue: 0.43)
                : Color(red: 0.98, green: 0.30, blue: 0.30)
        }
        return DarkDS.lime
    }

    // MARK: Underscore Row

    private var underscoreRow: some View {
        HStack(spacing: 6) {
            if let word = viewModel.currentWord {
                ForEach(0..<word.word.count, id: \.self) { idx in
                    Capsule()
                        .fill(DarkDS.card2)
                        .frame(width: 32, height: 4)
                        .opacity(idx >= viewModel.userAnswer.count ? 1 : 0)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 4)
    }

    // MARK: Letters Grid

    private var lettersGrid: some View {
        VStack(spacing: 10) {
            Text("Available letters")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(DarkDS.muted)
                .frame(maxWidth: .infinity, alignment: .leading)

            let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(viewModel.scrambledLetters.enumerated()), id: \.offset) { idx, letter in
                    Button { viewModel.tapLetter(letter, at: idx) } label: {
                        Text(letter.uppercased())
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(LotusApp.ink)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(RoundedRectangle(cornerRadius: 12).fill(DarkDS.card2))
                    }
                    .buttonStyle(PressScaleStyle())
                    .disabled(viewModel.isCorrect != nil)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    // MARK: Finished Screen

    private var finishedScreen: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle().fill(DarkDS.lime.opacity(0.10)).frame(width: 140, height: 140)
                Circle().fill(DarkDS.lime.opacity(0.20)).frame(width: 100, height: 100)
                Image(systemName: "star.fill")
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(DarkDS.lime)
            }
            VStack(spacing: 10) {
                Text("Well done!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("You completed the Word Scramble")
                    .font(.system(size: 15))
                    .foregroundStyle(DarkDS.muted)
            }
            HStack(spacing: 14) {
                scoreStatCard(label: "Score",    value: "\(viewModel.score)/8")
                scoreStatCard(label: "Accuracy", value: viewModel.round > 0 ? "\(Int(Double(viewModel.score) / Double(viewModel.round) * 100))%" : "—")
            }
            .padding(.horizontal, 24)

            Text("+15 XP earned")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 24).padding(.vertical, 10)
                .background(Capsule().fill(DarkDS.lime))

            Button {
                let dayKey = Int(Date().timeIntervalSince1970 / 86400)
                appState.awardXPOnce(key: "word_scramble_\(dayKey)", amount: 15)
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 24)
            Spacer()
        }
        .onAppear {
            let dayKey = Int(Date().timeIntervalSince1970 / 86400)
            appState.awardXPOnce(key: "word_scramble_\(dayKey)", amount: 15)
        }
    }

    private func scoreStatCard(label: String, value: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    // MARK: Shake

    private func triggerShake() {
        HapticService.shared.notify(.error)
        let anim = Animation.easeInOut(duration: 0.07)
        withAnimation(anim) { shakeOffset = -8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            withAnimation(anim) { shakeOffset = 8 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                withAnimation(anim) { shakeOffset = -6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                    withAnimation(anim) { shakeOffset = 6 }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
                        withAnimation(anim) { shakeOffset = 0 }
                    }
                }
            }
        }
    }
}
