import SwiftUI
import AVFoundation

struct MovieDetailView: View {
    let scene: MovieScene
    @Environment(\.dismiss) private var dismiss

    @State private var isPlaying = false
    @State private var speechRate: Float = 0.45
    @State private var showCultureNote = false
    private let synthesizer = AVSpeechSynthesizer()

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
                        .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.15))
                        .frame(width: 38, height: 38)
                    Image(systemName: "film")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            VStack(alignment: .leading, spacing: 6) {
                Text("MOVIE LESSON")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text(scene.movieTitle)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text(scene.sceneTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 24)
        }
    }

    // MARK: Content

    private var contentBody: some View {
        VStack(spacing: 16) {
            dialogueCard
            if !scene.expressions.isEmpty { expressionsCard }
            if scene.cultureNote != nil { cultureNoteCard }
            speedControl
            audioButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 0)
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

            if showCultureNote, let note = scene.cultureNote {
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

    // MARK: Dialogue Card

    private var dialogueCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "quote.bubble")
                    .font(.system(size: 14))
                    .foregroundStyle(DarkDS.muted)
                Text("Dialogue")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Text(scene.dialogue)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(LotusApp.ink)
                .fixedSize(horizontal: false, vertical: true)
            Divider().background(DarkDS.border)
            Text(scene.translation)
                .font(.system(size: 13))
                .foregroundStyle(DarkDS.muted)
                .italic()
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    // MARK: Expressions Card

    private var expressionsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                Text("Key Expressions")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }

            ForEach(scene.expressions) { expression in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\"\(expression.phrase)\"")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                    Text(expression.meaning)
                        .font(.system(size: 12))
                        .foregroundStyle(DarkDS.muted)
                }
                .padding(.vertical, 4)

                if expression.id != scene.expressions.last?.id {
                    Divider().background(DarkDS.border)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.10)))
    }

    // MARK: Audio Button

    private var audioButton: some View {
        Button { toggleAudio() } label: {
            HStack(spacing: 10) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18))
                Text(isPlaying ? "Stop" : "Listen to Dialogue")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(red: 0.22, green: 0.44, blue: 0.98)))
            .foregroundStyle(.white)
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: Helpers

    private func toggleAudio() {
        if isPlaying {
            synthesizer.stopSpeaking(at: .immediate)
            isPlaying = false
        } else {
            let utterance = AVSpeechUtterance(string: scene.dialogue)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            utterance.rate = speechRate
            synthesizer.speak(utterance)
            isPlaying = true
        }
    }
}
