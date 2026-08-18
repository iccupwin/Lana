import Foundation
import Combine

final class QuizMapViewModel: ObservableObject {
    @Published var worlds: [QuizWorld] = []

    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService = .shared) {
        self.sqliteService = sqliteService
        reload()
    }

    func reload() {
        let bestStars = sqliteService.fetchAllBestStars()
        worlds = QuizMapConfig.makeWorlds(bestStars: bestStars)
    }

    /// Returns computed stars, persists result, reloads map.
    @discardableResult
    func completeStage(stageId: String, correct: Int, total: Int) -> Int {
        let stars = starsFor(correct: correct, total: total)
        sqliteService.saveStageResult(stageId: stageId, stars: stars, correct: correct, total: total)
        reload()
        return stars
    }

    /// XP to award for the given stage result.
    func xpFor(stageId: String, stars: Int) -> Int {
        for world in worlds {
            if let stage = world.stages.first(where: { $0.id == stageId }) {
                return stage.xpReward + (stars == 3 ? stage.perfectXPBonus : 0)
            }
        }
        return 30
    }

    /// The first unlocked stage with 0 stars (next to play).
    var currentStage: QuizStage? {
        worlds.flatMap(\.stages).first { $0.isUnlocked && $0.bestStars == 0 }
    }

    /// Stage object by id.
    func stage(id: String) -> QuizStage? {
        worlds.flatMap(\.stages).first { $0.id == id }
    }
}
