import SwiftUI

// MARK: - LeaderboardWidget — Fix 6
// Replaced podium layout with a horizontally scrollable chip row.

struct LeaderboardWidget: View {
    let players: [LeaguePlayer]   // sorted descending by weeklyXP
    let userRank: Int
    let onViewAll: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            chipsRow
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Weekly league. You are ranked \(userRank) of \(players.count).")
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.appAmber)
                Text("Weekly league")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
            }
            Spacer()
            Button(action: onViewAll) {
                HStack(spacing: 3) {
                    Text("See all")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.appBlue)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("View full leaderboard")
        }
        .padding(.bottom, 14)
    }

    // MARK: - Horizontal chip row

    private var chipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(players.prefix(8).enumerated()), id: \.element.id) { index, player in
                    LeaguePlayerChip(rank: index + 1, player: player)
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - LeaguePlayerChip

private struct LeaguePlayerChip: View {
    let rank: Int
    let player: LeaguePlayer

    private var borderColor: Color {
        if player.isCurrentUser { return .appBlue }
        if rank == 1 { return .appAmber }
        return Color.white.opacity(0)
    }

    private var showBorder: Bool {
        player.isCurrentUser || rank == 1
    }

    var body: some View {
        HStack(spacing: 8) {
            // Rank number
            Text("#\(rank)")
                .font(.system(size: 11, weight: .black, design: .rounded))
                .foregroundStyle(rank == 1 ? Color.appAmber : .white.opacity(0.5))
                .frame(width: 22, alignment: .leading)

            // Avatar circle
            ZStack {
                Circle()
                    .fill(borderColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text((player.isCurrentUser ? "Y" : String(player.name.prefix(1))))
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(showBorder ? borderColor : .white.opacity(0.7))
            }

            // Name + XP
            VStack(alignment: .leading, spacing: 1) {
                Text(player.isCurrentUser ? "You" : (player.name.components(separatedBy: " ").first ?? player.name))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(player.weeklyXP) XP")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.appCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(borderColor, lineWidth: showBorder ? 1.5 : 0)
                )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(rank == 1 ? "1st" : rank == 2 ? "2nd" : rank == 3 ? "3rd" : "\(rank)th") place: \(player.isCurrentUser ? "you" : player.name), \(player.weeklyXP) XP"
        )
    }
}
