import SwiftUI

/// Static mission row used in the redesigned DailyMissionsCard.
/// Shows a coloured icon, title, "0/1 done" subtitle, and a mini progress bar.
struct MissionRowView: View {
    let title: String
    let icon: String
    let iconBackground: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon — 32×32 rounded rect
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconBackground)
                    .frame(width: 32, height: 32)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
            }

            // Title + subtitle
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("0/1 done")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }

            Spacer()

            // Mini progress bar — 48pt wide, 4pt tall
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.appTrackBg)
                    .frame(width: 48, height: 4)
                // Progress is 0 so fill width is 0; bar shown for layout consistency
                Capsule()
                    .fill(Color.appBlue)
                    .frame(width: 0, height: 4)
            }
        }
        .padding(.vertical, 4)
    }
}
