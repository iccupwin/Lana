import Foundation
import Combine

// Achievement metadata for Home display (mirrors AppState's private table)
private let homeAchievementMeta: [String: (icon: String, title: String)] = [
    "first_lesson":           ("graduationcap.fill",               "First Step"),
    "five_lessons":           ("books.vertical.fill",              "Bookworm"),
    "all_lessons":            ("star.fill",                        "Scholar"),
    "first_quiz":             ("checkmark.circle.fill",            "Quiz Taker"),
    "perfect_quiz":           ("medal.fill",                       "Perfectionist"),
    "quiz_master":            ("trophy.fill",                      "Quiz Master"),
    "word_saver":             ("bookmark.fill",                    "Word Saver"),
    "word_collector":         ("bookmark.circle.fill",             "Collector"),
    "words_50":               ("books.vertical.fill",              "Vocab Pro"),
    "words_100":              ("text.book.closed.fill",            "Lexicon Master"),
    "streak_3":               ("flame.fill",                       "On Fire"),
    "streak_7":               ("bolt.fill",                        "Week Warrior"),
    "streak_30":              ("bolt.circle.fill",                 "Unstoppable"),
    "xp_100":                 ("sparkles",                         "Rising Star"),
    "xp_500":                 ("crown.fill",                       "Pro Learner"),
    "xp_1000":                ("medal.fill",                       "Champion"),
    "xp_5000":                ("crown.fill",                       "Legend"),
    "level_5":                ("rosette",                          "Level 5 Reached"),
    "level_10":               ("trophy.fill",                      "Level 10 Pro"),
    "level_20":               ("crown.fill",                       "English Expert"),
    "quiz_world_1":           ("map.fill",                         "Foundations Complete"),
    "quiz_world_2":           ("map.fill",                         "Everyday Life Complete"),
    "quiz_world_3":           ("crown.fill",                       "Express Yourself Complete"),
    "quiz_world_4":           ("trophy.fill",                      "Quiz Master"),
]

// Preferred display order (highest tier first) for picking the "latest" achievement
private let achievementDisplayOrder: [String] = [
    "quiz_world_4", "level_20", "xp_5000", "xp_1000", "quiz_world_3",
    "level_10", "xp_500", "quiz_world_2", "streak_30", "all_lessons",
    "words_100", "quiz_world_1", "level_5", "xp_100", "streak_7",
    "quiz_master", "words_50", "word_collector", "perfect_quiz",
    "streak_3", "five_lessons", "word_saver", "first_quiz",
    "first_lesson",
]

final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentStreak: Int = 0
    @Published var activityDays: [Bool] = Array(repeating: false, count: 7)
    @Published var dailyQuests: [DailyQuest] = []
    @Published var dailyXP: [Int] = Array(repeating: 0, count: 7)
    @Published var motivationalMessage: String = "Start your streak today! 🚀"
    @Published var dailyGoalProgress: Double = 0.0
    @Published var userName: String = ""
    @Published var worlds: [QuizWorld] = []
    @Published var isLoading: Bool = true

    /// Title of the next recommended lesson (first incomplete, or last if all done)
    @Published var nextLessonTitle: String = "Start Learning"
    /// Name of the current active quiz world
    @Published var currentWorldName: String = "Foundations"
    /// Human-readable stage progress, e.g. "2/2 stages"
    @Published var worldProgress: String = "0/2 stages"
    /// How many stages in the current world are done (0–stagesInWorld)
    @Published var worldStagesDone: Int = 0
    @Published var worldStagesTotal: Int = 2

    /// Most prestigious unlocked achievement
    @Published var latestAchievementIcon: String? = nil
    @Published var latestAchievementTitle: String? = nil

    // MARK: - Dependencies

    private let sqliteService: SQLiteService

    // MARK: - Init

    init(sqliteService: SQLiteService = .shared) {
        self.sqliteService = sqliteService
    }

    // MARK: - Refresh

    func refresh(appState: AppState) {
        isLoading = false

        // User name from UserDefaults (shared with ProfileViewModel)
        userName = UserDefaults.standard.string(forKey: "userName") ?? ""

        // Quiz worlds for SkillPathPreviewCard
        let bestStars = sqliteService.fetchAllBestStars()
        worlds = QuizMapConfig.makeWorlds(bestStars: bestStars)

        let stats = sqliteService.fetchProgress()

        // Streak
        currentStreak = stats.currentStreak
        motivationalMessage = Self.motivationalMessage(for: currentStreak)

        // 7-day activity dots (Sun=0 … today)
        let activeDayOffsets = sqliteService.fetchActivityDays(last: 7)
        activityDays = (0..<7).map { activeDayOffsets.contains($0) }

        // Daily XP chart
        dailyXP = sqliteService.fetchDailyXP(days: 7)
        dailyGoalProgress = min(Double(dailyXP.last ?? 0) / 50.0, 1.0)

        // Daily quests
        dailyQuests = QuestService.shared.generateDailyQuests()

        // World progress
        let allStars = sqliteService.fetchAllBestStars()
        let worlds = QuizMapConfig.makeWorlds(bestStars: allStars)
        if let activeWorld = worlds.first(where: { !$0.isFullyComplete }) ?? worlds.last {
            currentWorldName = activeWorld.name
            worldStagesDone = activeWorld.completedStages
            worldStagesTotal = activeWorld.stages.count
            worldProgress = "\(activeWorld.completedStages)/\(activeWorld.stages.count) stages"
        }

        // Next lesson title (based on static lesson order from LessonsViewModel)
        let orderedLessons: [(id: String, title: String)] = [
            ("health",   "Health Care"),
            ("tv",       "Favorite TV Series"),
            ("food",     "Food & Cooking"),
            ("work",     "Work & Career"),
            ("travel",   "Places to Visit"),
            ("personal", "Personal Information"),
            ("hobbies",  "Your Hobbies"),
            ("future",   "Future Plans"),
        ]
        let completedIds = appState.completedLessonIds
        let next = orderedLessons.first(where: { !completedIds.contains($0.id) })
            ?? orderedLessons.last
        nextLessonTitle = next?.title ?? "Start Learning"

        // Latest (highest-tier) achievement
        let unlocked = appState.unlockedAchievementIds
        if let topId = achievementDisplayOrder.first(where: { unlocked.contains($0) }),
           let meta = homeAchievementMeta[topId] {
            latestAchievementIcon  = meta.icon
            latestAchievementTitle = meta.title
        } else {
            latestAchievementIcon  = nil
            latestAchievementTitle = nil
        }
    }

    // MARK: - Motivational Message

    static func motivationalMessage(for streak: Int) -> String {
        switch streak {
        case 0:        return "Start your streak today! 🚀"
        case 1:        return "Great start! Come back tomorrow 💪"
        case 2:        return "2 days in a row! Keep it up 🔥"
        case 3...6:    return "\(streak) days in a row! You're on fire 🔥"
        case 7...13:   return "One week strong! Incredible 🏅"
        case 14...29:  return "\(streak) day streak! You're unstoppable 💎"
        case 30...89:  return "\(streak) days! You're a legend 🏆"
        case 90...:    return "\(streak) days! Hall of Fame 👑"
        default:       return "Keep learning every day! 📚"
        }
    }

    // MARK: - Streak Card Subtitle

    static func streakCardSubtitle(for streak: Int) -> String {
        switch streak {
        case 0:        return "No streak yet"
        case 1...2:    return "Just started!"
        case 3...6:    return "Building habit!"
        default:       return "🔥 On fire!"
        }
    }
}
