import SwiftUI

struct XPChartView: View {
    let dailyXP: [Int]   // 7 values, index 0 = oldest, 6 = today

    @State private var animated = false

    private var maxValue: Double { max(Double(dailyXP.max() ?? 0), 20) }
    private var totalXP: Int { dailyXP.reduce(0, +) }

    private var hasData: Bool { dailyXP.contains(where: { $0 > 0 }) }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                    Text("XP This Week")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                Spacer()
                Text("\(totalXP) XP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Capsule().fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.2)))
            }

            if hasData {
                // Bars
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(0..<7, id: \.self) { i in
                        barColumn(index: i)
                    }
                }
                .frame(height: 110)
            } else {
                // Empty state
                VStack(spacing: 10) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.secondary)
                    Text("Start learning to see your progress")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.15)) {
                animated = true
            }
        }
    }

    private func barColumn(index: Int) -> some View {
        let xp       = index < dailyXP.count ? dailyXP[index] : 0
        let fraction = Double(xp) / maxValue
        let isToday  = index == 6
        let barH: CGFloat = animated ? max(4, 90 * fraction) : 4
        let barColor: Color = isToday
            ? Color(red: 0.20, green: 0.78, blue: 0.43)
            : Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.55)

        return VStack(spacing: 3) {
            // XP label on top
            Text(xp > 0 ? "\(xp)" : "")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .frame(height: 10)

            // Bar
            VStack {
                Spacer(minLength: 0)
                RoundedRectangle(cornerRadius: 4)
                    .fill(barColor)
                    .frame(height: barH)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.07),
                        value: animated
                    )
            }
            .frame(height: 90)

            // Day label
            Text(dayLabel(index))
                .font(.system(size: 9, weight: isToday ? .bold : .medium, design: .rounded))
                .foregroundStyle(isToday ? .white : DarkDS.muted)

            // Today dot
            Circle()
                .fill(isToday ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color.clear)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity)
    }

    private func dayLabel(_ index: Int) -> String {
        let daysAgo = 6 - index
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let f = DateFormatter()
        f.dateFormat = "E"
        return String(f.string(from: date).prefix(1))
    }
}
