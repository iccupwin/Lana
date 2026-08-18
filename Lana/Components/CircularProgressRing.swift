import SwiftUI

/// Animated circular progress ring used on lesson cards.
struct CircularProgressRing: View {
    let progress: Double    // 0.0 – 1.0
    let size: CGFloat
    let lineWidth: CGFloat
    let trackColor: Color
    let ringColor: Color
    let showCheckWhenComplete: Bool

    init(
        progress: Double,
        size: CGFloat = 36,
        lineWidth: CGFloat = 3,
        trackColor: Color = Color.white.opacity(0.15),
        ringColor: Color = Color(red: 0.773, green: 0.945, blue: 0.196),
        showCheckWhenComplete: Bool = true
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.trackColor = trackColor
        self.ringColor = ringColor
        self.showCheckWhenComplete = showCheckWhenComplete
    }

    @State private var animated = false

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
                .frame(width: size, height: size)

            // Progress arc
            Circle()
                .trim(from: 0, to: animated ? progress : 0)
                .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1), value: animated)

            // Center content
            if showCheckWhenComplete && progress >= 1.0 {
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.32, weight: .bold))
                    .foregroundStyle(ringColor)
            } else if progress > 0 {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .onAppear {
            animated = true
        }
    }
}
