import SwiftUI

struct HomeHeroCard: View {
    let userName: String
    let level: Int
    let levelName: String
    let totalXP: Int
    let currentStreak: Int
    let hearts: Int
    let todayXP: Int
    let xpProgress: Double
    let xpToNext: Int
    let onStartLesson: () -> Void

    @State private var cardScale: CGFloat = 0.95
    @State private var cardOpacity: Double = 0
    @State private var contentOffset: CGFloat = 30
    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            levelProgressSection
                .padding(.top, 16)
            statRow
                .padding(.top, 14)
            dailyGoalRow
                .padding(.top, 14)
            actionSection
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appCard)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .scaleEffect(cardScale)
        .opacity(cardOpacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                contentOffset = 0
                contentOpacity = 1.0
            }
        }
    }

    // MARK: - 1. Header: avatar + greeting + level subtitle

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            initialsAvatar

            VStack(alignment: .leading, spacing: 4) {
                Text(greetingLine)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Level \(level) · \(levelName)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    /// 40×40 circle showing user initials — Fix 2
    private var initialsAvatar: some View {
        ZStack {
            Circle()
                .fill(Color.appAvatarBg)
                .frame(width: 40, height: 40)
            Text(initials)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.appAvatarText)
        }
    }

    // MARK: - 2. Level XP progress (kept from original)

    private var levelProgressSection: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.appBlue.opacity(0.2))
                            .frame(width: 28, height: 28)
                        Text("\(level)")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundStyle(Color.appBlue)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text(levelName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Level \(level)")
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.appGreen)
                    Text("\(xpToNext) XP to next")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // XP progress bar toward next level
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appTrackBg)
                        .frame(height: 6)
                    Capsule()
                        .fill(Color(hex: "378ADD"))
                        .frame(width: geo.size.width * min(1, max(0, xpProgress)), height: 6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: xpProgress)
                }
            }
            .frame(height: 6)
        }
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    // MARK: - 3. Stat row — streak / XP / lives — Fix 3

    private var statRow: some View {
        HStack(spacing: 10) {
            statColumn(
                icon: "flame.fill",
                iconColor: .orange,
                value: "\(currentStreak)",
                label: "Day streak"
            )
            statColumn(
                icon: "bolt.fill",
                iconColor: .appBlue,
                value: "\(totalXP)",
                label: "Total XP"
            )
            statColumn(
                icon: "heart.fill",
                iconColor: .appDanger,
                value: "\(hearts)",
                label: "Lives"
            )
        }
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    private func statColumn(icon: String, iconColor: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(iconColor)
            Text(value)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.appStatBg)
        )
    }

    // MARK: - 4. Daily goal progress bar — Fix 4

    private var dailyGoalRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Daily goal")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.6))
                Spacer()
                Text("\(todayXP) / 50 XP")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.appBlue)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.appTrackBg)
                        .frame(height: 6)
                    Capsule()
                        .fill(Color.appBlue)
                        .frame(width: geo.size.width * min(1, Double(todayXP) / 50.0), height: 6)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: todayXP)
                }
            }
            .frame(height: 6)

            if todayXP == 0 {
                Text("Complete an activity to start")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    // MARK: - 5. CTA button — blue — Fix 1

    private var actionSection: some View {
        Button(action: onStartLesson) {
            HStack(spacing: 12) {
                Image(systemName: "play.fill")
                    .font(.system(size: 18, weight: .bold))
                Text("Start Today's Lesson")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.appBlue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(ScaleButtonStyle())
        .padding(.top, 20)
        .offset(y: contentOffset)
        .opacity(contentOpacity)
    }

    // MARK: - Helpers

    private var initials: String {
        let parts = userName.split(separator: " ").map { String($0) }
        if parts.count >= 2 {
            return (String(parts[0].prefix(1)) + String(parts[1].prefix(1))).uppercased()
        } else if let first = parts.first, !first.isEmpty {
            return String(first.prefix(2)).uppercased()
        }
        return "U"
    }

    /// "Good afternoon, Alex" when name is known; "Good afternoon!" when empty.
    private var greetingLine: String {
        let first = userName.split(separator: " ").first.map(String.init) ?? ""
        if first.isEmpty {
            return "\(greetingText)!"
        }
        return "\(greetingText), \(first)"
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        switch h {
        case 6..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default:      return "Good night"
        }
    }
}

// MARK: - LevelProgressBar (kept for backward compatibility)

struct LevelProgressBar: View {
    let progress: Double
    let height: CGFloat

    init(progress: Double, height: CGFloat = 8) {
        self.progress = progress
        self.height = height
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: height)
                Capsule()
                    .fill(Color.appGreen)
                    .frame(width: geo.size.width * min(1, max(0, progress)), height: height)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}
