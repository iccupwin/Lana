import SwiftUI

struct WordMasteryBadge: View {
    let level: WordMasteryLevel
    var showLabel: Bool = true

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: level.icon)
                .font(.system(size: 10, weight: .bold))
            if showLabel {
                Text(level.label)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
            }
        }
        .foregroundStyle(.white.opacity(0.9))
        .padding(.horizontal, showLabel ? 7 : 5)
        .padding(.vertical, 3)
        .background(Capsule().fill(level.color.opacity(0.6)))
    }
}
