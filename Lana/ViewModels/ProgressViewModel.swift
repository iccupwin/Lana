import Foundation
import Combine

struct AchievementItem {
    let id: String
    let icon: String
    let title: String
    let description: String
}

final class ProgressViewModel: ObservableObject {
    @Published var stats: ProgressStats = ProgressStats(quizzesTaken: 0, correctAnswers: 0, learnedWords: 0, currentStreak: 0)
    @Published var totalXP: Int = 0
    @Published var levelInfo: LevelInfo = SQLiteService.level(for: 0)
    @Published var unlockedAchievementIds: Set<String> = []
    @Published var activityDays: Set<Int> = []

    let sqliteService: SQLiteService

    static let allAchievements: [AchievementItem] = [
        AchievementItem(id: "first_lesson",   icon: "graduationcap.fill",    title: "First Step",   description: "Complete first lesson"),
        AchievementItem(id: "five_lessons",   icon: "books.vertical.fill",   title: "Bookworm",     description: "Complete 5 lessons"),
        AchievementItem(id: "all_lessons",    icon: "star.fill",             title: "Scholar",      description: "Complete all lessons"),
        AchievementItem(id: "first_quiz",     icon: "checkmark.circle.fill", title: "Quiz Taker",   description: "Take first quiz"),
        AchievementItem(id: "quiz_master",    icon: "trophy.fill",           title: "Quiz Master",  description: "Complete 10 quizzes"),
        AchievementItem(id: "word_saver",     icon: "bookmark.fill",         title: "Word Saver",   description: "Save 5 words"),
        AchievementItem(id: "word_collector", icon: "bookmark.circle.fill",  title: "Collector",    description: "Save 20 words"),
        AchievementItem(id: "streak_3",       icon: "flame.fill",            title: "On Fire",      description: "3-day streak"),
        AchievementItem(id: "streak_7",       icon: "bolt.fill",             title: "Week Warrior", description: "7-day streak"),
        AchievementItem(id: "xp_100",         icon: "sparkles",              title: "Rising Star",  description: "Earn 100 XP"),
        AchievementItem(id: "xp_500",         icon: "crown.fill",            title: "Pro Learner",  description: "Earn 500 XP"),
        AchievementItem(id: "xp_1000",        icon: "medal.fill",            title: "Champion",     description: "Earn 1000 XP"),
    ]

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        refresh()
    }

    func refresh() {
        stats = sqliteService.fetchProgress()
        totalXP = sqliteService.fetchTotalXP()
        levelInfo = SQLiteService.level(for: totalXP)
        unlockedAchievementIds = sqliteService.fetchUnlockedAchievementIds()
        activityDays = sqliteService.fetchActivityDays(last: 7)
    }
}
