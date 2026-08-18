import Foundation

final class QuestService {
    static let shared = QuestService()
    private let sqliteService: SQLiteService

    private init() {
        self.sqliteService = .shared
    }

    // MARK: - Date Key

    private var todayKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    // MARK: - Quest Templates
    // (type, title, descriptionTemplate, icon, goal, xpReward)

    private let templates: [(QuestType, String, String, String, Int, Int)] = [
        (.earnXP,         "XP Grinder",     "Earn {goal} XP today",           "sparkles",              50, 20),
        (.completeLesson, "Scholar",         "Complete {goal} lesson",         "book.fill",              1, 30),
        (.saveWords,      "Word Collector",  "Save {goal} new words",          "bookmark.fill",          3, 20),
        (.takeQuiz,       "Quiz Champion",   "Take {goal} quiz",               "checkmark.circle.fill",  1, 25),
        (.reviewWords,    "Flashcard Pro",   "Review {goal} flashcards",       "rectangle.stack.fill",   5, 15),
        (.earnXP,         "Power Hour",      "Earn {goal} XP in one session",  "bolt.fill",             30, 15),
    ]

    // MARK: - Public API

    /// Returns the 3 quests for today. Selection is deterministic per calendar date
    /// so quests are stable for the entire day across multiple calls.
    func generateDailyQuests() -> [DailyQuest] {
        // Use a bitmask to avoid abs(Int.min) overflow on 64-bit platforms.
        let safeHash = todayKey.hashValue & 0x7FFFFFFFFFFFFFFF

        var pool = templates
        var selectedTemplates: [(QuestType, String, String, String, Int, Int)] = []

        for i in 0..<3 {
            guard !pool.isEmpty else { break }
            let idx = (safeHash + i * 37) % pool.count
            selectedTemplates.append(pool[idx])
            pool.remove(at: idx)
        }

        var result: [DailyQuest] = []
        for (slotIndex, t) in selectedTemplates.enumerated() {
            let questId = "\(todayKey)_\(slotIndex)"
            let progress = fetchQuestProgress(key: questId)
            let description = t.2.replacingOccurrences(of: "{goal}", with: "\(t.4)")
            result.append(DailyQuest(
                id: questId,
                type: t.0,
                title: t.1,
                description: description,
                icon: t.3,
                goal: t.4,
                progress: progress,
                xpReward: t.5,
                completed: progress >= t.4
            ))
        }
        return result
    }

    /// Call this whenever the user performs an action that maps to a quest type.
    /// Finds the first incomplete quest of that type for today, increments its
    /// progress, and awards XP once when the quest is completed.
    func updateQuestProgress(type: QuestType, increment: Int = 1) {
        let quests = generateDailyQuests()
        for quest in quests where quest.type == type && !quest.completed {
            let newValue = min(quest.goal, quest.progress + increment)
            saveQuestProgress(key: quest.id, value: newValue)
            if newValue >= quest.goal {
                // addXPOnce guards against double-awarding via a day-keyed DB flag.
                sqliteService.addXPOnce(key: "quest_\(quest.id)", amount: quest.xpReward)
            }
            break   // only advance the first matching incomplete quest
        }
    }

    // MARK: - Private Persistence

    private func fetchQuestProgress(key: String) -> Int {
        return sqliteService.fetchUserStat(key: "quest_prog_\(key)") ?? 0
    }

    private func saveQuestProgress(key: String, value: Int) {
        sqliteService.setUserStat(key: "quest_prog_\(key)", value: value)
    }
}
