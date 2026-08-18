import SwiftUI

struct PronunciationPracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: PronunciationPracticeViewModel

    @State private var recordPulse = false
    @State private var showXPBadge = false

    init(sqliteService: SQLiteService) {
        _viewModel = StateObject(wrappedValue: PronunciationPracticeViewModel(sqliteService: sqliteService))
    }

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                header
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        if let word = viewModel.currentWord {
                            wordCard(word: word)
                        } else {
                            emptyState
                        }
                        actionButtons
                        if viewModel.hasRecording && viewModel.selfRating == nil {
                            ratingSection
                        }
                        if let rating = viewModel.selfRating {
                            afterRatingSection(rating: rating)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .center) {
            if showXPBadge {
                Text("+10 XP")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(Capsule().fill(DarkDS.lime))
                    .transition(.scale.combined(with: .opacity))
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            VStack(spacing: 2) {
                Text("SPEAKING")
                    .font(.system(size: 9, weight: .black, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Pronunciation")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Word Card

    private func wordCard(word: SavedWord) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(DarkDS.lime.opacity(0.12))
                    .frame(width: 90, height: 90)
                Image(systemName: "waveform")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(DarkDS.lime)
            }
            Text(word.word)
                .font(.system(size: 38, weight: .bold))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
            Text(word.translation)
                .font(.system(size: 16))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .padding(.horizontal, 24)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 48))
                .foregroundStyle(DarkDS.muted.opacity(0.5))
            Text("No saved words")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Text("Save some words first to practice pronunciation.")
                .font(.system(size: 14))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    // MARK: Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(
                icon: viewModel.isPlaying ? "speaker.wave.3.fill" : "speaker.wave.2.fill",
                label: "Listen",
                color: Color(red: 0.22, green: 0.44, blue: 0.98),
                isActive: viewModel.isPlaying
            ) {
                guard !viewModel.isPlaying else { return }
                viewModel.speakWord()
            }

            actionButton(
                icon: viewModel.isRecording ? "stop.circle.fill" : "mic.fill",
                label: viewModel.isRecording ? "Stop" : "Record",
                color: Color(red: 0.98, green: 0.30, blue: 0.30),
                isActive: viewModel.isRecording
            ) {
                HapticService.shared.impact(.light)
                if viewModel.isRecording { viewModel.stopRecording() }
                else { viewModel.startRecording() }
            }
            .overlay(
                viewModel.isRecording
                    ? RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.red.opacity(recordPulse ? 0.8 : 0.2), lineWidth: 2)
                        .animation(.easeInOut(duration: 0.7).repeatForever(), value: recordPulse)
                    : nil
            )
            .onAppear { recordPulse = true }

            actionButton(
                icon: "play.fill",
                label: "Play Back",
                color: viewModel.hasRecording ? Color(red: 0.20, green: 0.78, blue: 0.43) : DarkDS.card2,
                isActive: false
            ) {
                viewModel.playRecording()
            }
            .disabled(!viewModel.hasRecording)
            .opacity(viewModel.hasRecording ? 1.0 : 0.4)
        }
    }

    private func actionButton(icon: String, label: String, color: Color, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.opacity(isActive ? 0.9 : 0.18))
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(isActive ? .white : color)
                        .scaleEffect(isActive ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: isActive)
                }
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DarkDS.muted)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: Rating Section

    private var ratingSection: some View {
        VStack(spacing: 14) {
            Text("How did you do?")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            HStack(spacing: 10) {
                ratingButton(label: "Hard",  color: Color(red: 0.98, green: 0.30, blue: 0.30), quality: 1)
                ratingButton(label: "OK",    color: Color(red: 0.98, green: 0.79, blue: 0.20), quality: 3)
                ratingButton(label: "Great!",color: DarkDS.lime,                               quality: 5)
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    private func ratingButton(label: String, color: Color, quality: Int) -> some View {
        Button {
            HapticService.shared.impact(.medium)
            viewModel.submitRating(quality)
            if quality >= 3 {
                withAnimation(.spring(response: 0.4)) { showXPBadge = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation { showXPBadge = false }
                }
            }
        } label: {
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(color.opacity(quality == 5 ? 1.0 : 0.25)))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: After Rating

    private func afterRatingSection(rating: Int) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                Text("Recorded!")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                if rating >= 3 {
                    Text("+10 XP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Capsule().fill(DarkDS.lime))
                }
            }
            Button { viewModel.nextWord() } label: {
                HStack(spacing: 8) {
                    Text("Next Word")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }
}
