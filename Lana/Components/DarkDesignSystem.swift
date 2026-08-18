import SwiftUI

/// Compatibility tokens for legacy lesson views.
///
/// The original app used a dark charcoal/lime system throughout the learning
/// flow. Keeping these names lets the existing exercise logic stay untouched
/// while every screen inherits the current light Lotus/Aurora language.
enum DarkDS {
    static let bg     = LotusApp.pearl
    static let card   = Color.white.opacity(0.86)
    static let card2  = LotusApp.ink.opacity(0.055)
    static let lime   = LotusApp.cobalt
    static let muted  = LotusApp.muted
    static let border = LotusApp.ink.opacity(0.075)
    static let r: CGFloat = 20

    // Gradient helpers
    static let limeGradient = LinearGradient(
        colors: [LotusApp.aqua, LotusApp.cobalt, LotusApp.violet],
        startPoint: .leading, endPoint: .trailing
    )
    static let blueGradient = LinearGradient(
        colors: [LotusApp.aqua, LotusApp.cobalt],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let purpleGradient = LinearGradient(
        colors: [LotusApp.cobalt, LotusApp.violet],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let orangeGradient = LinearGradient(
        colors: [LotusApp.violet, LotusApp.coral],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    // Level colors
    static let levelColors: [Color] = [
        LotusApp.cobalt,
        LotusApp.mint,
        LotusApp.violet,
        LotusApp.amber
    ]
}

// MARK: - Reusable Lotus back button

struct DarkBackButton: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button { dismiss() } label: {
            Circle()
                .fill(Color.white.opacity(0.90))
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.white, lineWidth: 1))
                .shadow(color: LotusApp.ink.opacity(0.08), radius: 10, y: 4)
                .overlay(
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lotus screen wrapper

struct DarkScreen<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        LotusAppScreen {
            content()
        }
        .navigationBarHidden(true)
    }
}
