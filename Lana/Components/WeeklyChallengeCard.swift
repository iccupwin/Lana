import SwiftUI

struct WeeklyChallengeCard: View {
    let weeklyXP: Int

    @AppStorage("weeklyXPGoal") private var goal: Int = 300
    @State private var showGoalPicker = false

    private var progress: Double { goal > 0 ? min(1, Double(weeklyXP) / Double(goal)) : 0 }
    private var isComplete: Bool { weeklyXP >= goal }

    private let goals: [(Int, String, String)] = [
        (150, "Easy",   "leaf.fill"),
        (300, "Medium", "flame.fill"),
        (500, "Hard",   "bolt.fill"),
        (750, "Expert", "trophy.fill"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                    Text("Weekly Challenge")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                Button { showGoalPicker = true } label: {
                    Text("Change")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(DarkDS.card2))
                }
                .buttonStyle(PressScaleStyle())
            }

            // Progress numbers
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(weeklyXP)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                Text("/ \(goal) XP")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                Spacer()
                if isComplete {
                    Label("Complete!", systemImage: "checkmark.seal.fill")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15)))
                } else {
                    Text("\(goal - weeklyXP) XP to go")
                        .font(.system(size: 11, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(DarkDS.card2)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.22, green: 0.44, blue: 0.98), Color(red: 0.20, green: 0.78, blue: 0.43)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 10)
                        .animation(.spring(response: 0.6), value: progress)

                    // Goal milestones
                    ForEach([0.25, 0.5, 0.75], id: \.self) { frac in
                        Circle()
                            .fill(progress >= frac ? Color(red: 0.20, green: 0.78, blue: 0.43) : DarkDS.card2)
                            .frame(width: 6, height: 6)
                            .offset(x: geo.size.width * frac - 3)
                    }
                }
            }
            .frame(height: 10)

            // Goal level chips
            HStack(spacing: 8) {
                ForEach(goals, id: \.0) { xp, label, icon in
                    let isSelected = goal == xp
                    Button { goal = xp } label: {
                        HStack(spacing: 4) {
                            Image(systemName: icon)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundStyle(isSelected ? .black : DarkDS.muted)
                            Text(label)
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(isSelected ? .black : DarkDS.muted)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(isSelected ? DarkDS.lime : DarkDS.card2))
                    }
                    .buttonStyle(PressScaleStyle())
                }
                Spacer()
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }
}
