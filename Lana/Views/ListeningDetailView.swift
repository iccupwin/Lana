import SwiftUI
import AVFoundation

struct ListeningDetailView: View {
    let exercise: ListeningExercise
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    @State private var isPlaying = false
    @State private var showTranscript = false
    @State private var selectedAnswers: [String: Int] = [:]
    @State private var showResult = false
    @State private var speechRate: Float = 0.45
    @State private var showCultureNote = false

    private let synthesizer = AVSpeechSynthesizer()

    private var score: Int {
        exercise.questions.filter { q in selectedAnswers[q.id] == q.correctIndex }.count
    }

    private var allAnswered: Bool {
        exercise.questions.allSatisfy { selectedAnswers[$0.id] != nil }
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    pageHeader
                    contentBody
                }
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                DarkBackButton()
                Spacer()
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: "headphones")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(alignment: .leading, spacing: 6) {
                Text("LISTENING")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text(exercise.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
    }

    // MARK: Content

    private var contentBody: some View {
        VStack(spacing: 16) {
            if exercise.cultureNote != nil { cultureNoteCard }
            speedControl
            audioCard
            transcriptCard
            questionsSection
            if allAnswered && !showResult {
                Button {
                    withAnimation { showResult = true }
                    appState.awardXPOnce(key: "listening_\(exercise.id)", amount: 25)
                } label: {
                    Text("Check Answers")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
                }
                .buttonStyle(PressScaleStyle())
            }
            if showResult { resultCard }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
    }

    // MARK: Culture Note

    private var cultureNoteCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { showCultureNote.toggle() }
            } label: {
                HStack {
                    Image(systemName: "globe")
                        .font(.system(size: 13))
                        .foregroundStyle(DarkDS.muted)
                    Text("Culture Note")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Spacer()
                    Image(systemName: showCultureNote ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DarkDS.muted)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
            }
            .buttonStyle(.plain)

            if showCultureNote, let note = exercise.cultureNote {
                Text(note)
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.08)))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: Speed Control

    private var speedControl: some View {
        HStack(spacing: 8) {
            Text("Speed")
                .font(.system(size: 12))
                .foregroundStyle(DarkDS.muted)
            Spacer()
            ForEach([("0.75×", Float(0.35)), ("1.0×", Float(0.45)), ("1.25×", Float(0.52)), ("1.5×", Float(0.58))], id: \.0) { label, rate in
                Button {
                    speechRate = rate
                    if isPlaying {
                        synthesizer.stopSpeaking(at: .immediate)
                        isPlaying = false
                    }
                } label: {
                    let isSelected = speechRate == rate
                    Text(label)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(isSelected ? .white : DarkDS.muted)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Capsule().fill(isSelected ? DarkDS.lime : DarkDS.card2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: Audio Card

    private var audioCard: some View {
        HStack(spacing: 16) {
            Button { toggleAudio() } label: {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                        .frame(width: 52, height: 52)
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(isPlaying ? "Playing..." : "Tap to listen")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("Listen carefully, then answer below")
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.10)))
    }

    // MARK: Transcript Card

    private var transcriptCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) { showTranscript.toggle() }
            } label: {
                HStack {
                    Image(systemName: "text.quote")
                        .font(.system(size: 13))
                        .foregroundStyle(DarkDS.muted)
                    Text("Transcript")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Spacer()
                    Image(systemName: showTranscript ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DarkDS.muted)
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
            }
            .buttonStyle(.plain)

            if showTranscript {
                Text(exercise.transcript)
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                    .padding(16)
                    .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card2))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: Questions

    private var questionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                Text("Questions")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }

            ForEach(Array(exercise.questions.enumerated()), id: \.element.id) { i, question in
                questionCard(index: i, question: question)
            }
        }
    }

    private func questionCard(index: Int, question: QuizQuestion) -> some View {
        let selected = selectedAnswers[question.id]
        let isCorrect = selected == question.correctIndex

        return VStack(alignment: .leading, spacing: 10) {
            Text("Q\(index + 1). \(question.text)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(question.options.indices, id: \.self) { idx in
                Button {
                    if !showResult { selectedAnswers[question.id] = idx }
                } label: {
                    HStack {
                        Text(question.options[idx])
                            .font(.system(size: 13))
                            .foregroundStyle(listeningOptionText(selected: selected, idx: idx, correct: question.correctIndex))
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if let sel = selected, sel == idx {
                            Image(systemName: showResult
                                  ? (sel == question.correctIndex ? "checkmark.circle.fill" : "xmark.circle.fill")
                                  : "circle.fill")
                                .foregroundStyle(showResult
                                                 ? (sel == question.correctIndex
                                                    ? Color(red: 0.20, green: 0.78, blue: 0.43)
                                                    : Color(red: 0.98, green: 0.30, blue: 0.30))
                                                 : Color(red: 0.98, green: 0.79, blue: 0.20))
                        }
                    }
                    .padding(11)
                    .background(RoundedRectangle(cornerRadius: 12).fill(listeningOptionBg(selected: selected, idx: idx, correct: question.correctIndex)))
                }
                .buttonStyle(.plain)
                .disabled(showResult)
            }

            if showResult, let sel = selected {
                Text(sel == question.correctIndex ? "Correct!" : "Correct answer: \(question.options[question.correctIndex])")
                    .font(.system(size: 11))
                    .foregroundStyle(isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color(red: 0.98, green: 0.30, blue: 0.30))
                if !question.explanation.isEmpty {
                    Text(question.explanation)
                        .font(.system(size: 11))
                        .foregroundStyle(DarkDS.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    // MARK: Result Card

    private var resultCard: some View {
        let perfect = score == exercise.questions.count
        return VStack(spacing: 12) {
            Image(systemName: perfect ? "star.fill" : "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(perfect ? DarkDS.lime : Color(red: 0.20, green: 0.78, blue: 0.43))
            Text("\(score) / \(exercise.questions.count) correct")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(perfect ? "Perfect! Excellent listening!" : "Good job! Keep practising.")
                .font(.system(size: 13))
                .foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 20).fill(perfect ? DarkDS.lime.opacity(0.10) : Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.10)))
    }

    // MARK: Helpers

    private func toggleAudio() {
        if isPlaying {
            synthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
        } else {
            let utterance = AVSpeechUtterance(string: exercise.transcript)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
            utterance.rate = speechRate
            synthesizer.speak(utterance)
            isPlaying = true
        }
    }

    private func listeningOptionBg(selected: Int?, idx: Int, correct: Int) -> Color {
        guard let sel = selected else { return DarkDS.card2 }
        if sel == idx {
            if showResult { return sel == correct ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15) : Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12) }
            return Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15)
        }
        if showResult && idx == correct { return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.10) }
        return DarkDS.card2
    }

    private func listeningOptionText(selected: Int?, idx: Int, correct: Int) -> Color {
        guard let sel = selected, showResult else { return LotusApp.ink }
        if idx == correct { return Color(red: 0.20, green: 0.78, blue: 0.43) }
        if sel == idx { return Color(red: 0.98, green: 0.30, blue: 0.30) }
        return DarkDS.muted
    }
}
