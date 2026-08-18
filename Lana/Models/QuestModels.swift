import Foundation

enum QuestType: String, CaseIterable {
    case earnXP         = "earn_xp"
    case completeLesson = "complete_lesson"
    case saveWords      = "save_words"
    case takeQuiz       = "take_quiz"
    case reviewWords    = "review_words"
    case openApp        = "open_app"
}

struct DailyQuest: Identifiable {
    let id: String          // e.g. "2024-01-01_0"
    let type: QuestType
    let title: String
    let description: String
    let icon: String        // SF Symbol name
    let goal: Int
    var progress: Int
    let xpReward: Int
    var completed: Bool

    var fraction: Double {
        goal <= 0 ? 1.0 : min(1.0, Double(progress) / Double(goal))
    }
}
