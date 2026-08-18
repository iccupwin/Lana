import Foundation
import Combine

struct LeaguePlayer: Identifiable {
    let id: String
    let name: String
    let countryCode: String  // 2-letter ISO code, replaces emoji for iOS 26 compatibility
    let weeklyXP: Int
    let isCurrentUser: Bool
}

final class LeagueViewModel: ObservableObject {
    @Published var players: [LeaguePlayer] = []
    @Published var userRank: Int = 1

    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        load()
    }

    func load() {
        let userXP = sqliteService.fetchWeeklyXP()
        let week = Calendar(identifier: .iso8601).component(.weekOfYear, from: Date())

        let mockData: [(String, String, String, Int)] = [
            ("p1", "Emma",    "GB", deterministicXP(seed: 1, week: week)),
            ("p2", "Liam",    "US", deterministicXP(seed: 2, week: week)),
            ("p3", "Sofia",   "DE", deterministicXP(seed: 3, week: week)),
            ("p4", "Yuki",    "JP", deterministicXP(seed: 4, week: week)),
            ("p5", "Carlos",  "ES", deterministicXP(seed: 5, week: week)),
            ("p6", "Priya",   "IN", deterministicXP(seed: 6, week: week)),
            ("p7", "Marcus",  "ZA", deterministicXP(seed: 7, week: week)),
            ("p8", "Anya",    "RU", deterministicXP(seed: 8, week: week)),
            ("p9", "Ji-woo",  "KR", deterministicXP(seed: 9, week: week)),
        ]

        var all = mockData.map { id, name, code, xp in
            LeaguePlayer(id: id, name: name, countryCode: code, weeklyXP: xp, isCurrentUser: false)
        }
        all.append(LeaguePlayer(id: "me", name: "You", countryCode: "ME", weeklyXP: userXP, isCurrentUser: true))
        all.sort { $0.weeklyXP > $1.weeklyXP }
        players = all
        userRank = (all.firstIndex { $0.id == "me" } ?? 0) + 1
    }

    private func deterministicXP(seed: Int, week: Int) -> Int {
        let base = [120, 95, 145, 80, 110, 135, 70, 160, 90][seed % 9]
        let variance = ((seed * week * 17) % 40) - 20
        return max(10, base + variance)
    }
}
