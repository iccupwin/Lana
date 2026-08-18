import SwiftUI

struct AudioQuizView: View {
    @StateObject private var viewModel = AudioQuizViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DarkScreen {
            if viewModel.isFinished {
                finishedView
            } else {
                quizContent
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                viewModel.speakCurrent()
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isFinished)
    }

    // MARK: Quiz Content

    private var quizContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                header
                progressBar
                if let q = viewModel.current {
                    speakCard(q)
                    optionsGrid(q)
                    if viewModel.isAnswered { nextButton }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 60)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            Text("Audio Quiz")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Text("\(viewModel.currentIndex + 1)/\(viewModel.questions.count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(DarkDS.card2))
        }
        .padding(.top, 16)
    }

    // MARK: Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(DarkDS.card2).frame(height: 6)
                Capsule().fill(Color(red: 0.22, green: 0.44, blue: 0.98))
                    .frame(width: geo.size.width * viewModel.progress, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: Speak Card

    private func speakCard(_ q: AudioQuizQuestion) -> some View {
        VStack(spacing: 20) {
            Text("What does this word mean?")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(DarkDS.muted)
                .padding(.horizontal, 10).padding(.vertical, 4)
                .background(Capsule().fill(DarkDS.card2))

            Button { viewModel.speakCurrent() } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.12))
                        .frame(width: 120, height: 120)
                        .scaleEffect(viewModel.isSpeaking ? 1.12 : 1.0)
                        .animation(
                            viewModel.isSpeaking
                                ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
                                : .default,
                            value: viewModel.isSpeaking
                        )
                    Circle()
                        .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.20))
                        .frame(width: 88, height: 88)
                    Image(systemName: viewModel.isSpeaking ? "speaker.wave.3.fill" : "speaker.wave.2.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                }
            }
            .buttonStyle(PressScaleStyle())

            Text("Tap to hear again")
                .font(.system(size: 11))
                .foregroundStyle(DarkDS.muted)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 24).fill(DarkDS.card))
    }

    // MARK: Options Grid

    private func optionsGrid(_ q: AudioQuizQuestion) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(q.options, id: \.self) { option in
                let selected  = viewModel.selectedOption == option
                let isCorrect = viewModel.isAnswered && option == q.correctTranslation
                let isWrong   = viewModel.isAnswered && selected && option != q.correctTranslation

                Button { viewModel.select(option) } label: {
                    HStack {
                        Text(option)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(LotusApp.ink)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if isCorrect {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                        } else if isWrong {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(Color(red: 0.98, green: 0.30, blue: 0.30))
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15) :
                                isWrong   ? Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.15) :
                                selected  ? Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.20) :
                                            DarkDS.card
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16).strokeBorder(
                                    isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.5) :
                                    isWrong   ? Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.5) :
                                    selected  ? Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.5) :
                                                DarkDS.border,
                                    lineWidth: 1.5
                                )
                            )
                    )
                }
                .buttonStyle(PressScaleStyle())
                .disabled(viewModel.isAnswered)
            }
        }
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
                Circle().fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.12)).frame(width: 130, height: 130)
                Circle().fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.22)).frame(width: 90, height: 90)
                Image(systemName: viewModel.score == viewModel.questions.count
                      ? "headphones" : "ear.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            }
            Text("\(viewModel.score)/\(viewModel.questions.count)")
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text("Listening score")
                .font(.system(size: 15))
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
            appState.awardXPOnce(key: "audio_quiz_\(Int(Date().timeIntervalSince1970 / 86_400))", amount: 20)
        }
    }
}
