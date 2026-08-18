import SwiftUI

/// Displays up to 5 heart icons + a regen countdown when hearts are depleted.
struct HeartsBarView: View {
    @ObservedObject private var service = HeartsService.shared

    var body: some View {
        HStack(spacing: 6) {
            // Heart icons
            HStack(spacing: 3) {
                ForEach(0..<HeartsService.max, id: \.self) { i in
                    Image(systemName: i < service.hearts ? "heart.fill" : "heart")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(i < service.hearts ? Color.red : DarkDS.muted)
                        .animation(.spring(response: 0.3, dampingFraction: 0.55), value: service.hearts)
                }
            }

            // Regen timer
            if !service.regenLabel.isEmpty {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                        .foregroundStyle(DarkDS.muted)
                    Text(service.regenLabel)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                        .monospacedDigit()
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(DarkDS.card2))
            }
        }
    }
}

/// Full "out of hearts" banner — shown when hearts == 0
struct OutOfHeartsView: View {
    @ObservedObject private var service = HeartsService.shared

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Color.red.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.red.opacity(0.8))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("No hearts left!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                if !service.regenLabel.isEmpty {
                    Text("Next heart in \(service.regenLabel)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.07))
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.red.opacity(0.2), lineWidth: 1))
        )
    }
}
