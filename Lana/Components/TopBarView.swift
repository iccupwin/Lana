import SwiftUI

struct TopBarView: View {
    let title: String
    let subtitle: String?
    let avatarSystemImage: String

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(Circle().fill(Color.white.opacity(0.12)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.bodyText(14))
                        .foregroundStyle(DesignSystem.softWhite)
                    if let subtitle {
                        Text(subtitle)
                            .font(.bodyText(11))
                            .foregroundStyle(DesignSystem.mutedWhite)
                    }
                }
            }
            Spacer()
            Image(systemName: avatarSystemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(Circle().fill(Color.white.opacity(0.12)))
        }
    }
}
