import SwiftUI

struct DailyQuestsCard: View {
    let quests: [DailyQuest]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerRow
            ForEach(quests) { quest in
                questRow(quest)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }

    // MARK: Header

    private var headerRow: some View {
        HStack {
            Label("Daily Quests", systemImage: "list.star")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            let done = quests.filter { $0.completed }.count
            Text("\(done)/\(quests.count)")
                .font(.system(size: 12))
                .foregroundStyle(DarkDS.muted)
        }
    }

    // MARK: Quest Row

    private func questRow(_ q: DailyQuest) -> some View {
        HStack(spacing: 12) {
            questIcon(q)
            questDetails(q)
        }
    }

    private func questIcon(_ q: DailyQuest) -> some View {
        ZStack {
            Circle()
                .fill(
                    q.completed
                        ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.20)
                        : Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15)
                )
                .frame(width: 38, height: 38)
            Image(systemName: q.completed ? "checkmark" : q.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(
                    q.completed
                        ? Color(red: 0.20, green: 0.78, blue: 0.43)
                        : Color(red: 0.98, green: 0.79, blue: 0.20)
                )
        }
    }

    private func questDetails(_ q: DailyQuest) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(q.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                xpBadge(q)
            }
            progressBar(q)
            Text(q.description)
                .font(.system(size: 10))
                .foregroundStyle(DarkDS.muted)
        }
    }

    private func xpBadge(_ q: DailyQuest) -> some View {
        Text("+\(q.xpReward) XP")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(q.completed ? .black : DarkDS.lime)
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(
                Capsule().fill(
                    q.completed
                        ? Color(red: 0.20, green: 0.78, blue: 0.43)
                        : DarkDS.lime.opacity(0.15)
                )
            )
    }

    private func progressBar(_ q: DailyQuest) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(DarkDS.card2)
                    .frame(height: 5)
                RoundedRectangle(cornerRadius: 3)
                    .fill(q.completed ? Color(red: 0.20, green: 0.78, blue: 0.43) : DarkDS.lime)
                    .frame(width: geo.size.width * q.fraction, height: 5)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: q.fraction)
            }
        }
        .frame(height: 5)
    }
}
