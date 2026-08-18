import SwiftUI

// MARK: - Difficulty

enum QuizDifficulty: String {
    case beginner           = "A1"
    case elementary         = "A1–A2"
    case preIntermediate    = "A2"
    case intermediate       = "A2–B1"
    case upperIntermediate  = "B1"
    case advanced           = "B1–B2"
    case proficient         = "B2"
    case expert             = "B2–C1"
}

// MARK: - Stage

struct QuizStage: Identifiable {
    let id: String                  // matches Quiz.id in quizzes.json
    let worldId: String
    let stageNumber: Int            // 1-based within the world (1 or 2)
    let globalIndex: Int            // 1-based across all stages (1…8)
    let title: String
    let difficulty: QuizDifficulty
    let xpReward: Int
    let perfectXPBonus: Int
    var bestStars: Int              // 0 = not played, 1–3
    var isUnlocked: Bool
}

// MARK: - World

struct QuizWorld: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let accentColor: Color
    let gradient: LinearGradient
    var stages: [QuizStage]

    var completedStages: Int { stages.filter { $0.bestStars > 0 }.count }
    var isFullyComplete: Bool { stages.allSatisfy { $0.bestStars > 0 } }
}

// MARK: - Star calculation

func starsFor(correct: Int, total: Int) -> Int {
    guard total > 0 else { return 0 }
    let ratio = Double(correct) / Double(total)
    switch ratio {
    case 1.0...:  return 3
    case 0.8...:  return 2
    case 0.5...:  return 1
    default:      return 0
    }
}

// MARK: - Static Map Config

enum QuizMapConfig {

    // Raw mapping: (quizId, worldId, stageNumber, globalIndex, title, difficulty, xp, bonusXP)
    private static let raw: [(String, String, Int, Int, String, QuizDifficulty, Int, Int)] = [
        ("quiz_basic",    "world_1", 1, 1, "Basic Grammar",     .beginner,          30, 15),
        ("quiz_travel",   "world_1", 2, 2, "Travel English",    .elementary,        35, 15),
        ("quiz_daily",    "world_2", 1, 3, "Daily Life",        .preIntermediate,   40, 15),
        ("quiz_tenses",   "world_2", 2, 4, "Tenses",            .intermediate,      45, 20),
        ("quiz_phrasal",  "world_3", 1, 5, "Phrasal Verbs",     .upperIntermediate, 50, 20),
        ("quiz_business", "world_3", 2, 6, "Business English",  .advanced,          55, 25),
        ("quiz_idioms",   "world_4", 1, 7, "Idioms",            .proficient,        60, 25),
        ("quiz_advanced", "world_4", 2, 8, "Advanced",          .expert,            70, 30),
    ]

    private static let worldMeta: [(id: String, name: String, subtitle: String, color: Color, gradient: LinearGradient)] = [
        ("world_1", "Foundations",       "A1 Essentials",    DarkDS.lime,
         LinearGradient(colors: [Color(red:0.773,green:0.945,blue:0.196), Color(red:0.62,green:0.82,blue:0.10)],
                        startPoint:.topLeading, endPoint:.bottomTrailing)),
        ("world_2", "Everyday Life",     "A2 – B1",          Color(red:0.22,green:0.44,blue:0.98),
         LinearGradient(colors: [Color(red:0.22,green:0.44,blue:0.98), Color(red:0.14,green:0.28,blue:0.75)],
                        startPoint:.topLeading, endPoint:.bottomTrailing)),
        ("world_3", "Express Yourself",  "B1 – B2",          Color(red:0.62,green:0.38,blue:0.98),
         LinearGradient(colors: [Color(red:0.62,green:0.38,blue:0.98), Color(red:0.44,green:0.22,blue:0.78)],
                        startPoint:.topLeading, endPoint:.bottomTrailing)),
        ("world_4", "Mastery",           "B2 – C1",          Color(red:0.98,green:0.60,blue:0.18),
         LinearGradient(colors: [Color(red:0.98,green:0.60,blue:0.18), Color(red:0.88,green:0.42,blue:0.08)],
                        startPoint:.topLeading, endPoint:.bottomTrailing)),
    ]

    static func makeWorlds(bestStars: [String: Int]) -> [QuizWorld] {
        // Build flat stages with unlock logic
        var stages: [QuizStage] = []
        for (idx, r) in raw.enumerated() {
            let stars = bestStars[r.0] ?? 0
            let unlocked: Bool
            if idx == 0 {
                unlocked = true
            } else {
                let prevId = raw[idx - 1].0
                unlocked = (bestStars[prevId] ?? 0) >= 1
            }
            stages.append(QuizStage(
                id: r.0, worldId: r.1, stageNumber: r.2, globalIndex: r.3,
                title: r.4, difficulty: r.5,
                xpReward: r.6, perfectXPBonus: r.7,
                bestStars: stars, isUnlocked: unlocked
            ))
        }

        // Group into worlds
        return worldMeta.map { meta in
            let worldStages = stages.filter { $0.worldId == meta.id }
            return QuizWorld(
                id: meta.id, name: meta.name, subtitle: meta.subtitle,
                accentColor: meta.color, gradient: meta.gradient,
                stages: worldStages
            )
        }
    }
}
