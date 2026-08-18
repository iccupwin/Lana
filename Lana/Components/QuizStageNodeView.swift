import SwiftUI

// MARK: - Stage Node View

struct QuizStageNodeView: View {
    let stage: QuizStage
    let accentColor: Color
    let gradient: LinearGradient
    let isCurrent: Bool
    let onTap: () -> Void

    @State private var pulse = false

    private let gold = Color(red: 0.98, green: 0.79, blue: 0.20)

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Pulse ring for current/available stage
                    if isCurrent && stage.isUnlocked && stage.bestStars == 0 {
                        Circle()
                            .stroke(accentColor.opacity(0.3), lineWidth: 6)
                            .frame(width: 76, height: 76)
                            .scaleEffect(pulse ? 1.22 : 1.0)
                            .opacity(pulse ? 0 : 0.7)
                            .animation(
                                .easeInOut(duration: 1.1).repeatForever(autoreverses: false),
                                value: pulse
                            )
                    }

                    // Node background
                    Circle()
                        .fill(nodeBg)
                        .frame(width: 66, height: 66)
                        .overlay(
                            Circle().strokeBorder(nodeBorder, lineWidth: 2.5)
                        )

                    // Icon
                    nodeIcon

                    // Global index badge
                    Text("\(stage.globalIndex)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(stage.isUnlocked ? .black : DarkDS.muted)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(
                            Capsule().fill(stage.isUnlocked ? accentColor : DarkDS.card2)
                        )
                        .offset(x: 22, y: -22)
                }

                // Stars row
                HStack(spacing: 4) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(i <= stage.bestStars ? gold : DarkDS.card2)
                    }
                }

                // "Play" label for current stage
                if isCurrent && stage.isUnlocked && stage.bestStars == 0 {
                    Text("PLAY")
                        .font(.system(size: 9, weight: .black, design: .rounded))
                        .foregroundStyle(accentColor)
                        .tracking(1.2)
                }
            }
        }
        .buttonStyle(PressScaleStyle(scale: 0.94))
        .disabled(!stage.isUnlocked)
        .onAppear { pulse = true }
    }

    // MARK: Node background

    private var nodeBg: AnyShapeStyle {
        if !stage.isUnlocked {
            return AnyShapeStyle(DarkDS.card)
        }
        if stage.bestStars == 3 {
            return AnyShapeStyle(gradient)
        }
        if stage.bestStars > 0 {
            return AnyShapeStyle(accentColor.opacity(0.55))
        }
        return AnyShapeStyle(DarkDS.bg)
    }

    private var nodeBorder: Color {
        if !stage.isUnlocked { return DarkDS.card2 }
        if stage.bestStars == 3 { return gold.opacity(0.6) }
        if stage.bestStars > 0 { return accentColor.opacity(0.5) }
        return accentColor
    }

    // MARK: Icon

    @ViewBuilder
    private var nodeIcon: some View {
        if !stage.isUnlocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(DarkDS.muted)
        } else if stage.bestStars == 3 {
            Image(systemName: "star.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(gold)
        } else if stage.bestStars > 0 {
            Image(systemName: "checkmark")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
        } else {
            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(accentColor)
        }
    }
}
