import SwiftUI

struct LightTopBarView: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 10) {
            // Avatar circle
            Circle()
                .fill(DarkDS.card)
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(DarkDS.muted)
                        .font(.system(size: 16))
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                Text(subtitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Spacer()

            // Settings button
            Circle()
                .fill(DarkDS.card)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(DarkDS.muted)
                )
        }
    }
}
