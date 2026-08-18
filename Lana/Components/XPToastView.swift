import SwiftUI

// MARK: - XP Toast (slides from top)

struct XPToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: message.hasPrefix("Level") ? "arrow.up.circle.fill" : "star.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.yellow)
            Text(message)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 11)
        .background(
            Capsule()
                .fill(Color(red: 0.08, green: 0.08, blue: 0.10).opacity(0.88))
                .shadow(color: .black.opacity(0.25), radius: 12, y: 4)
        )
    }
}

// MARK: - Achievement Banner (slides from bottom)

struct AchievementBannerView: View {
    let icon: String
    let title: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.22))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Achievement Unlocked!")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .tracking(0.5)
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.90))
                .shadow(color: .black.opacity(0.3), radius: 16, y: -4)
        )
        .padding(.horizontal, 16)
    }
}

// MARK: - Press Scale Button Style

struct PressScaleStyle: ButtonStyle {
    var scale: CGFloat = 0.97

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.65), value: configuration.isPressed)
    }
}
