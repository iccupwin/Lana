import SwiftUI

struct LeagueView: View {
    @StateObject private var viewModel: LeagueViewModel
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    init(sqliteService: SQLiteService) {
        _viewModel = StateObject(wrappedValue: LeagueViewModel(sqliteService: sqliteService))
    }

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    pageHeader
                    podium
                    leaderboard
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
    }

    // MARK: Header

    private var pageHeader: some View {
        HStack {
            DarkBackButton()
            VStack(alignment: .leading, spacing: 2) {
                Text("WEEKLY")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("League")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            }
        }
        .padding(.top, 16)
    }

    // MARK: Podium

    private var podium: some View {
        let top3 = Array(viewModel.players.prefix(3))
        guard top3.count >= 3 else { return AnyView(EmptyView()) }
        return AnyView(
            HStack(alignment: .bottom, spacing: 8) {
                podiumSlot(player: top3[1], rank: 2, height: 80)
                podiumSlot(player: top3[0], rank: 1, height: 110)
                podiumSlot(player: top3[2], rank: 3, height: 60)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
        )
    }

    private func podiumSlot(player: LeaguePlayer, rank: Int, height: CGFloat) -> some View {
        VStack(spacing: 6) {
            // Country code badge instead of flag emoji
            ZStack {
                Circle()
                    .fill(player.isCurrentUser ? DarkDS.lime.opacity(0.2) : DarkDS.card2)
                    .frame(width: rank == 1 ? 44 : 36, height: rank == 1 ? 44 : 36)
                Text(player.countryCode)
                    .font(.system(size: rank == 1 ? 12 : 10, weight: .black, design: .rounded))
                    .foregroundStyle(player.isCurrentUser ? DarkDS.lime : LotusApp.muted)
            }
            Text(player.name)
                .font(.system(size: rank == 1 ? 13 : 11, weight: .bold, design: .rounded))
                .foregroundStyle(player.isCurrentUser ? DarkDS.lime : LotusApp.ink)
                .lineLimit(1)
            Text("\(player.weeklyXP) XP")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(rankColor(rank).opacity(0.25))
                    .frame(height: height)
                Text("#\(rank)")
                    .font(.system(size: rank == 1 ? 20 : 16, weight: .black, design: .rounded))
                    .foregroundStyle(rankColor(rank))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color(red: 0.98, green: 0.79, blue: 0.20)   // gold
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.80)   // silver
        case 3: return Color(red: 0.80, green: 0.50, blue: 0.25)   // bronze
        default: return DarkDS.muted
        }
    }

    // MARK: Leaderboard

    private var leaderboard: some View {
        VStack(spacing: 2) {
            ForEach(viewModel.players.dropFirst(3).prefix(7)) { player in
                let rank = (viewModel.players.firstIndex { $0.id == player.id } ?? 0) + 1
                leaderboardRow(player: player, rank: rank)
                if rank < min(viewModel.players.count, 9) {
                    Divider().background(DarkDS.border).padding(.horizontal, 4)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    private func leaderboardRow(player: LeaguePlayer, rank: Int) -> some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .frame(width: 28)

            ZStack {
                Circle()
                    .fill(player.isCurrentUser ? DarkDS.lime.opacity(0.15) : DarkDS.card2)
                    .frame(width: 34, height: 34)
                Text(player.countryCode)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(player.isCurrentUser ? DarkDS.lime : LotusApp.muted)
            }

            Text(player.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(player.isCurrentUser ? DarkDS.lime : LotusApp.ink)
            Spacer()
            Text("\(player.weeklyXP) XP")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(player.isCurrentUser ? DarkDS.lime : DarkDS.muted)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            player.isCurrentUser
                ? RoundedRectangle(cornerRadius: 10).fill(DarkDS.lime.opacity(0.07))
                : RoundedRectangle(cornerRadius: 10).fill(Color.clear)
        )
    }
}
