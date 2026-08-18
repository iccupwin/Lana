import SwiftUI

struct DailyPhraseView: View {
    @StateObject private var viewModel: DailyPhraseViewModel
    @EnvironmentObject private var appState: AppState
    @State private var revealed = false

    init(repository: ContentRepository) {
        _viewModel = StateObject(wrappedValue: DailyPhraseViewModel(repository: repository))
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    pageHeader

                    if let phrase = viewModel.phrase {
                        phraseCard(phrase)
                        if revealed {
                            exampleCard(phrase)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    } else {
                        Text("No phrase available today.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(DarkDS.muted)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.awardXPOnce(key: "daily_phrase_\(todayKey)", amount: 10)
        }
    }

    private var todayKey: Int { Int(Date().timeIntervalSince1970 / 86_400) }

    private var pageHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("PHRASE OF THE DAY")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Daily Phrase")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.4))
                    .frame(width: 44, height: 44)
                Image(systemName: "text.bubble.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
            }
        }
        .padding(.top, 60)
    }

    private func phraseCard(_ phrase: DailyPhrase) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(phrase.type.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.5)))
                Spacer()
                Text(phrase.difficulty)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.5)))
            }

            Text(phrase.phrase)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(LotusApp.ink)

            Text(phrase.translation)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)

            if !revealed {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        revealed = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                        Text("Show Example")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(DarkDS.lime)
                    )
                }
                .buttonStyle(PressScaleStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(DarkDS.card)
        )
    }

    private func exampleCard(_ phrase: DailyPhrase) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Example", systemImage: "quote.opening")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)

            Text(phrase.exampleSentence)
                .font(.system(size: 18, weight: .medium, design: .serif))
                .foregroundStyle(LotusApp.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text(phrase.exampleTranslation)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.2))
        )
    }
}
