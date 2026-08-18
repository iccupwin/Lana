import SwiftUI

struct TrophyRoomView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedGroup: String = "All"

    private let cols = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]
    private let groupOptions = ["All"] + AchievementDef.groups

    private var displayed: [AchievementDef] {
        let base = selectedGroup == "All" ? AchievementDef.all : AchievementDef.all.filter { $0.group == selectedGroup }
        let unlocked = base.filter {  appState.unlockedAchievementIds.contains($0.id) }
        let locked    = base.filter { !appState.unlockedAchievementIds.contains($0.id) }
        return unlocked + locked
    }

    private var unlockedCount: Int {
        AchievementDef.all.filter { appState.unlockedAchievementIds.contains($0.id) }.count
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    summaryBanner
                    groupFilter
                    badgeGrid
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            }
        }
        .navigationBarHidden(true)
        .onAppear { appState.refreshAll() }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            VStack(spacing: 2) {
                Text("MY TROPHIES")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("Trophy Room")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.top, 16)
    }

    // MARK: Summary Banner

    private var summaryBanner: some View {
        HStack(spacing: 0) {
            summaryCell(value: "\(unlockedCount)",                                                    label: "Unlocked",  icon: "trophy.fill",     color: Color(red: 0.98, green: 0.79, blue: 0.20))
            Divider().frame(height: 50).background(DarkDS.border)
            summaryCell(value: "\(AchievementDef.all.count - unlockedCount)",                         label: "Remaining", icon: "lock.fill",        color: DarkDS.muted)
            Divider().frame(height: 50).background(DarkDS.border)
            summaryCell(value: "\(Int(Double(unlockedCount) / Double(AchievementDef.all.count) * 100))%", label: "Complete",  icon: "chart.pie.fill",  color: Color(red: 0.20, green: 0.78, blue: 0.43))
        }
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
    }

    private func summaryCell(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label).font(.system(size: 10)).foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }

    // MARK: Group Filter

    private var groupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(groupOptions, id: \.self) { group in
                    let isSelected = selectedGroup == group
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedGroup = group
                        }
                    } label: {
                        Text(group)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(isSelected ? .white : LotusApp.muted)
                            .padding(.horizontal, 14).padding(.vertical, 7)
                            .background(Capsule().fill(isSelected ? DarkDS.lime : DarkDS.card2))
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
        }
    }

    // MARK: Badge Grid

    private var badgeGrid: some View {
        LazyVGrid(columns: cols, spacing: 14) {
            ForEach(displayed) { def in
                let isUnlocked = appState.unlockedAchievementIds.contains(def.id)
                achievementCard(def, isUnlocked: isUnlocked)
            }
        }
    }

    private func achievementCard(_ def: AchievementDef, isUnlocked: Bool) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? def.color.opacity(0.18) : DarkDS.card2)
                    .frame(width: 60, height: 60)
                if isUnlocked {
                    Image(systemName: def.icon)
                        .font(.system(size: 26))
                        .foregroundStyle(def.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(DarkDS.muted.opacity(0.4))
                }
            }

            Text(def.title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(isUnlocked ? LotusApp.ink : DarkDS.muted)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(def.description)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            if isUnlocked {
                Text("Unlocked")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15)))
            } else {
                Text(def.group)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(DarkDS.card2))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(isUnlocked ? DarkDS.card : DarkDS.card.opacity(0.5)))
        .opacity(isUnlocked ? 1 : 0.65)
    }
}
