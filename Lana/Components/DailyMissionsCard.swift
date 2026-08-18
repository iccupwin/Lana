import SwiftUI

// MARK: - DailyMissionsCard — Fix 5
// Always-expanded, 2 static mission rows. No accordion, no 0/0 counter.

struct DailyMissionsCard: View {
    // Keep signature unchanged so HomeView call requires no change.
    let quests: [DailyQuest]
    let onQuestTap: (DailyQuest) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            MissionRowView(
                title: "Complete 1 lesson",
                icon: "book.fill",
                iconBackground: Color.appBlue
            )
            Divider()
                .background(Color.white.opacity(0.08))
            MissionRowView(
                title: "Study for 5 minutes",
                icon: "clock.fill",
                iconBackground: Color.appGreen
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.14, green: 0.14, blue: 0.16))
        )
    }

    private var sectionHeader: some View {
        Text("DAILY MISSIONS")
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white.opacity(0.35))
            .tracking(0.8)
    }
}
