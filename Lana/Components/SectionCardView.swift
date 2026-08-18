import SwiftUI

struct SectionCardView: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        ColoredCard(color: color) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.title(18))
                        .foregroundStyle(DesignSystem.darkInk)
                    Text(subtitle)
                        .font(.bodyText(12))
                        .foregroundStyle(DesignSystem.darkInk.opacity(0.7))
                }
                Spacer()
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignSystem.darkInk)
                    .padding(10)
                    .background(Circle().fill(Color.white.opacity(0.35)))
            }
        }
    }
}
