import SwiftUI

struct QuizStageResultView: View {
    let stageTitle: String
    let correct: Int
    let total: Int
    let stars: Int          // 0–3
    let xpEarned: Int
    let nextUnlocked: Bool  // показать badge "Stage Unlocked!"
    let onContinue: () -> Void
    let onRetry: () -> Void

    @State private var star1 = false
    @State private var star2 = false
    @State private var star3 = false
    @State private var showXP = false
    @State private var showUnlock = false
    @State private var showConfettiOverlay = false

    private let gold   = Color(red: 0.98, green: 0.79, blue: 0.20)
    private let dimmed = Color(white: 0.25)

    var body: some View {
        ZStack {
            LotusApp.pearl.ignoresSafeArea()
            Image("LotusAuroraBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.34)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("LotusResultBloom")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 154)
                    .accessibilityHidden(true)

                // Stars
                HStack(spacing: 20) {
                    starView(index: 1, active: star1)
                    starView(index: 0, active: star1)   // center star slightly larger
                        .scaleEffect(star2 ? 1.25 : 0.8)
                        .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.3), value: star2)
                    starView(index: 2, active: star3)
                }
                .padding(.bottom, 28)

                // Stage title
                Text(stageTitle)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                    .padding(.bottom, 6)

                // Score
                Text("\(correct) / \(total) correct")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.bottom, 24)

                // XP badge
                if showXP {
                    HStack(spacing: 6) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                        Text("+\(xpEarned) XP")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(LotusApp.aurora))
                    .transition(.scale(scale: 0.6).combined(with: .opacity))
                    .padding(.bottom, 12)
                }

                // Unlock badge
                if showUnlock {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(gold)
                        Text("Next Stage Unlocked!")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(gold)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(gold.opacity(0.12))
                            .overlay(Capsule().strokeBorder(gold.opacity(0.4), lineWidth: 1))
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 12)
                }

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(RoundedRectangle(cornerRadius: 18).fill(LotusApp.aurora))
                    }
                    .buttonStyle(PressScaleStyle())

                    Button(action: onRetry) {
                        Text("Try Again")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(LotusApp.ink.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(DarkDS.border, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(PressScaleStyle())
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }

            // Confetti overlay
            if showConfettiOverlay {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .preferredColorScheme(.light)
        .onAppear { runAnimation() }
    }

    // MARK: Star view

    private func starView(index: Int, active: Bool) -> some View {
        let filled = starsEarned(index: index)
        return Image(systemName: "star.fill")
            .font(.system(size: index == 0 ? 52 : 38, weight: .bold))
            .foregroundStyle(filled ? gold : dimmed)
            .scaleEffect(filled ? 1.0 : 0.85)
            .animation(
                .spring(response: 0.45, dampingFraction: 0.55)
                    .delay(Double(index) * 0.3),
                value: filled
            )
    }

    private func starsEarned(index: Int) -> Bool {
        switch index {
        case 0: return star1   // center (always first)
        case 1: return star2
        case 2: return star3
        default: return false
        }
    }

    // MARK: Animation sequence

    private func runAnimation() {
        // Star 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation { star1 = stars >= 1 }
            HapticService.shared.impact(.medium)
        }
        // Star 2
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation { star2 = stars >= 2 }
            if stars >= 2 { HapticService.shared.impact(.medium) }
        }
        // Star 3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation { star3 = stars >= 3 }
            if stars >= 3 {
                HapticService.shared.notify(.success)
                showConfettiOverlay = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    showConfettiOverlay = false
                }
            }
        }
        // XP badge
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { showXP = true }
        }
        // Unlock badge
        if nextUnlocked {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { showUnlock = true }
            }
        }
    }
}
