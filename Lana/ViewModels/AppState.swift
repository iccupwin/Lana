import Foundation
import Combine
import UIKit

private let achievementMeta: [String: (icon: String, title: String)] = [
    "first_lesson":            ("graduationcap.fill",                "First Step"),
    "five_lessons":            ("books.vertical.fill",               "Bookworm"),
    "all_lessons":             ("star.fill",                         "Scholar"),
    "first_quiz":              ("checkmark.circle.fill",             "Quiz Taker"),
    "perfect_quiz":            ("medal.fill",                        "Perfectionist"),
    "quiz_master":             ("trophy.fill",                       "Quiz Master"),
    "word_saver":              ("bookmark.fill",                     "Word Saver"),
    "word_collector":          ("bookmark.circle.fill",              "Collector"),
    "words_50":                ("books.vertical.fill",               "Vocab Pro"),
    "words_100":               ("text.book.closed.fill",             "Lexicon Master"),
    "streak_3":                ("flame.fill",                        "On Fire"),
    "streak_7":                ("bolt.fill",                         "Week Warrior"),
    "streak_30":               ("bolt.circle.fill",                  "Unstoppable"),
    "xp_100":                  ("sparkles",                          "Rising Star"),
    "xp_500":                  ("crown.fill",                        "Pro Learner"),
    "xp_1000":                 ("medal.fill",                        "Champion"),
    "xp_5000":                 ("crown.fill",                        "Legend"),
    "first_mistake_review":    ("arrow.uturn.backward.circle.fill",  "Learner"),
    "first_typing":            ("keyboard.fill",                     "Typist"),
    "first_audio_quiz":        ("ear.fill",                          "Good Ear"),
    "first_match_madness":     ("square.grid.2x2.fill",              "Memory Match"),
    "first_sentence_builder":  ("text.alignleft",                    "Sentence Maker"),
    "level_5":                 ("rosette",                           "Level 5 Reached"),
    "level_10":                ("trophy.fill",                       "Level 10 Pro"),
    "level_20":                ("crown.fill",                        "English Expert"),
    "quiz_world_1":            ("map.fill",                          "Foundations Complete"),
    "quiz_world_2":            ("map.fill",                          "Everyday Life Complete"),
    "quiz_world_3":            ("crown.fill",                        "Express Yourself Complete"),
    "quiz_world_4":            ("trophy.fill",                       "Quiz Master"),
]

final class AppState: ObservableObject {
    let contentRepository: ContentRepository
    let sqliteService: SQLiteService

    @Published var totalXP: Int = 0
    @Published var weeklyXP: Int = 0
    @Published var levelInfo: LevelInfo = SQLiteService.level(for: 0)
    @Published var cefrLevel: CEFRLevel = .a1
    @Published var completedLessonIds: Set<String> = []
    @Published var unlockedAchievementIds: Set<String> = []
    @Published var todayActivitiesCount: Int = 0

    // Toast / overlay notifications
    @Published var xpToastMessage: String? = nil
    @Published var achievementToast: (icon: String, title: String)? = nil
    @Published var showLevelUpPulse: Bool = false
    @Published var pendingLevelUp: LevelInfo? = nil

    private var toastWork: DispatchWorkItem?
    private var achievementWork: DispatchWorkItem?

    init(contentRepository: ContentRepository = JSONContentService(), sqliteService: SQLiteService = .shared) {
        self.contentRepository = contentRepository
        self.sqliteService = sqliteService
        refreshAll()
    }

    func refreshAll() {
        totalXP = sqliteService.fetchTotalXP()
        weeklyXP = sqliteService.fetchWeeklyXP()
        levelInfo = SQLiteService.level(for: totalXP)
        cefrLevel = CEFRLevel.level(for: totalXP)
        completedLessonIds = sqliteService.fetchCompletedLessonIds()
        unlockedAchievementIds = sqliteService.fetchUnlockedAchievementIds()
        todayActivitiesCount = sqliteService.fetchTodayActivityCount()
    }

    func awardXP(_ amount: Int) {
        let previousXP = totalXP
        let oldLevel = levelInfo.level
        sqliteService.addXP(amount)
        totalXP = sqliteService.fetchTotalXP()
        levelInfo = SQLiteService.level(for: totalXP)
        // Award a streak freeze at every 100-XP milestone crossed.
        if (totalXP / 100) > (previousXP / 100) {
            sqliteService.earnStreakFreeze()
        }
        if levelInfo.level > oldLevel {
            pendingLevelUp = levelInfo
            triggerLevelUpPulse()
        } else {
            HapticService.shared.impact(.light)
            showXPToast("+\(amount) XP")
        }
        checkAchievements()
    }

    @discardableResult
    func awardXPOnce(key: String, amount: Int) -> Bool {
        let awarded = sqliteService.addXPOnce(key: key, amount: amount)
        if awarded {
            let oldLevel = levelInfo.level
            totalXP = sqliteService.fetchTotalXP()
            levelInfo = SQLiteService.level(for: totalXP)
            todayActivitiesCount = min(todayActivitiesCount + 1, 3)
            if levelInfo.level > oldLevel {
                pendingLevelUp = levelInfo
                triggerLevelUpPulse()
            } else {
                HapticService.shared.impact(.light)
                showXPToast("+\(amount) XP")
            }
            checkAchievements()
        }
        return awarded
    }

    func markLessonComplete(_ lessonId: String) {
        sqliteService.markLessonComplete(lessonId)
        completedLessonIds = sqliteService.fetchCompletedLessonIds()
        awardXPOnce(key: "lesson_\(lessonId)", amount: 20)
        checkAchievements()
    }

    func checkAchievements() {
        let stats = sqliteService.fetchProgress()
        let completedCount = completedLessonIds.count
        let allStars = sqliteService.fetchAllBestStars()
        let world1Done = ["quiz_basic","quiz_travel"].allSatisfy { (allStars[$0] ?? 0) >= 1 }
        let world2Done = ["quiz_daily","quiz_tenses"].allSatisfy { (allStars[$0] ?? 0) >= 1 }
        let world3Done = ["quiz_phrasal","quiz_business"].allSatisfy { (allStars[$0] ?? 0) >= 1 }
        let world4Done = ["quiz_idioms","quiz_advanced"].allSatisfy { (allStars[$0] ?? 0) >= 1 }

        let checks: [(id: String, condition: Bool)] = [
            ("first_lesson",   completedCount >= 1),
            ("five_lessons",   completedCount >= 5),
            ("all_lessons",    completedCount >= 8),
            ("first_quiz",     stats.quizzesTaken >= 1),
            ("quiz_master",    stats.quizzesTaken >= 10),
            ("word_saver",     stats.learnedWords >= 5),
            ("word_collector", stats.learnedWords >= 20),
            ("words_50",       stats.learnedWords >= 50),
            ("words_100",      stats.learnedWords >= 100),
            ("streak_3",       stats.currentStreak >= 3),
            ("streak_7",       stats.currentStreak >= 7),
            ("streak_30",      stats.currentStreak >= 30),
            ("xp_100",         totalXP >= 100),
            ("xp_500",         totalXP >= 500),
            ("xp_1000",        totalXP >= 1000),
            ("xp_5000",        totalXP >= 5000),
            ("level_5",        levelInfo.level >= 5),
            ("level_10",       levelInfo.level >= 10),
            ("level_20",       levelInfo.level >= 20),
            ("quiz_world_1",   world1Done),
            ("quiz_world_2",   world2Done),
            ("quiz_world_3",   world3Done),
            ("quiz_world_4",   world4Done),
        ]
        var firstNew: String? = nil
        for check in checks where check.condition && !unlockedAchievementIds.contains(check.id) {
            sqliteService.unlockAchievement(check.id)
            if firstNew == nil { firstNew = check.id }
        }
        unlockedAchievementIds = sqliteService.fetchUnlockedAchievementIds()
        if let id = firstNew, let meta = achievementMeta[id] {
            showAchievementToast(icon: meta.icon, title: meta.title)
        }
    }

    /// Unlock a specific achievement by ID (for one-time triggers like first match, first typing, etc.)
    func triggerAchievement(_ id: String) {
        guard !unlockedAchievementIds.contains(id) else { return }
        sqliteService.unlockAchievement(id)
        unlockedAchievementIds = sqliteService.fetchUnlockedAchievementIds()
        if let meta = achievementMeta[id] {
            showAchievementToast(icon: meta.icon, title: meta.title)
        }
    }

    // MARK: - Toast helpers

    private func showXPToast(_ message: String) {
        toastWork?.cancel()
        xpToastMessage = message
        let work = DispatchWorkItem { [weak self] in self?.xpToastMessage = nil }
        toastWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: work)
    }

    private func showAchievementToast(icon: String, title: String) {
        HapticService.shared.notify(.success)
        achievementWork?.cancel()
        achievementToast = (icon: icon, title: title)
        let work = DispatchWorkItem { [weak self] in self?.achievementToast = nil }
        achievementWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5, execute: work)
    }

    private func triggerLevelUpPulse() {
        showLevelUpPulse = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showLevelUpPulse = false
        }
    }
}
