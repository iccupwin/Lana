import SwiftUI
import AVFoundation

struct WordOfDayView: View {
    @ObservedObject var viewModel: WordOfDayViewModel
    @EnvironmentObject private var appState: AppState
    private let synthesizer = AVSpeechSynthesizer()

    private var todayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d\nMMM"
        return formatter.string(from: Date()).uppercased()
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    pageHeader
                    wordCard
                    navigationButtons
                    vocabularyCard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            appState.awardXPOnce(key: "word_of_day", amount: 10)
        }
    }

    // MARK: Header

    private var pageHeader: some View {
        HStack {
            DarkBackButton()
            Spacer()
            VStack(spacing: 2) {
                Text("DAILY")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Word of the Day")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "text.badge.star")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
            }
        }
        .padding(.top, 16)
    }

    // MARK: Word Card

    private var wordCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Word of the Day")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                Text(todayLabel)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .multilineTextAlignment(.center)
                    .padding(8)
                    .background(Circle().fill(DarkDS.card2))
            }

            if let word = viewModel.currentWord {
                Text(word.word)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                    .padding(.vertical, 4)

                HStack(spacing: 8) {
                    if let cefr = word.cefr {
                        Text(cefr)
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color(red: 0.98, green: 0.79, blue: 0.20)))
                    }
                    if let register = word.register, register != "neutral" {
                        Text(register.capitalized)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundStyle(LotusApp.ink)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(registerColor(register)))
                    }
                }

                HStack(spacing: 12) {
                    Text(word.phonetic)
                        .font(.system(size: 13))
                        .foregroundStyle(DarkDS.muted)
                    Spacer()

                    Button {
                        let utterance = AVSpeechUtterance(string: word.word)
                        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                        utterance.rate = 0.45
                        synthesizer.speak(utterance)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                            .padding(9)
                            .background(Circle().fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15)))
                    }

                    Button {
                        viewModel.saveCurrentWord()
                    } label: {
                        Image(systemName: "bookmark.fill")
                            .foregroundStyle(DarkDS.lime)
                            .padding(9)
                            .background(Circle().fill(DarkDS.lime.opacity(0.12)))
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Label(word.translation, systemImage: "globe")
                        .font(.system(size: 13))
                        .foregroundStyle(LotusApp.ink.opacity(0.88))

                    Text("\"\(word.example)\"")
                        .font(.system(size: 12))
                        .foregroundStyle(DarkDS.muted)
                        .italic()
                        .fixedSize(horizontal: false, vertical: true)

                    if let collocations = word.collocations, !collocations.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Common phrases:")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(DarkDS.muted)
                                .padding(.top, 4)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 6) {
                                    ForEach(collocations, id: \.self) { phrase in
                                        Text(phrase)
                                            .font(.system(size: 10))
                                            .foregroundStyle(LotusApp.ink)
                                            .padding(.horizontal, 8).padding(.vertical, 4)
                                            .background(Capsule().fill(DarkDS.card2))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                Text("No word for today yet.")
                    .font(.system(size: 14))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.10)))
    }

    private func registerColor(_ register: String) -> Color {
        switch register {
        case "formal":   return Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.7)
        case "informal": return Color(red: 0.98, green: 0.55, blue: 0.20).opacity(0.7)
        case "slang":    return Color(red: 0.98, green: 0.30, blue: 0.60).opacity(0.7)
        case "british":  return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.7)
        case "american": return Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.7)
        default:         return DarkDS.card2
        }
    }

    // MARK: Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            Button { viewModel.previousWord() } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))
            }
            .buttonStyle(PressScaleStyle())

            Button { viewModel.nextWord() } label: {
                HStack {
                    Text("Next")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
        }
    }

    // MARK: Vocabulary Card

    private var vocabularyCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Vocabulary List")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("31 essential English words")
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
                Text("Word \(viewModel.currentIndex + 1) of \(viewModel.words.count)")
                    .font(.system(size: 11))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.top, 4)
            }
            Spacer()
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.6))
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.10)))
    }
}
