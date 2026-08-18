import SwiftUI

/// Animated circular ring showing today's XP progress toward the daily goal.
struct DailyGoalRingView: View {
    let current: Int   // XP earned today
    let goal: Int      // daily XP goal
    let size: CGFloat

    init(current: Int, goal: Int = 50, size: CGFloat = 44) {
        self.current = current
        self.goal    = goal
        self.size    = size
    }

    @State private var animated = false

    private var fraction: Double { min(Double(current) / Double(max(goal, 1)), 1.0) }
    private var isComplete: Bool  { current >= goal }

    private let trackWidth: CGFloat = 3

    var body: some View {
        ZStack {
            // 1. Track circle
            Circle()
                .stroke(DarkDS.card2, lineWidth: trackWidth)
                .frame(width: size, height: size)

            // 2. Progress arc — lime gradient, spring-animated on appear
            Circle()
                .trim(from: 0, to: animated ? fraction : 0)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.773, green: 0.945, blue: 0.196),
                            Color(red: 0.62,  green: 0.82,  blue: 0.10)
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle:   .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: trackWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.7, dampingFraction: 0.75), value: animated)

            // 3. Center content
            if isComplete {
                Image(systemName: "bolt.fill")
                    .font(.system(size: size * 0.28, weight: .bold))
                    .foregroundStyle(DarkDS.lime)
            } else {
                Text("\(current)")
                    .font(.system(size: size * 0.28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .onAppear {
            animated = true
        }
        .onChange(of: fraction) { _ in
            // Re-trigger if XP changes while view is visible
            animated = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                animated = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 20) {
        DailyGoalRingView(current: 0,  goal: 50, size: 44)
        DailyGoalRingView(current: 25, goal: 50, size: 44)
        DailyGoalRingView(current: 50, goal: 50, size: 44)
    }
    .padding()
    .background(DarkDS.bg)
}
