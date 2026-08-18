import Foundation
import SQLite3

/// SQLite-backed storage for user data (saved words, quiz results, streak, SRS reviews, XP, achievements).
final class SQLiteService {
    static let shared = SQLiteService()

    private var db: OpaquePointer?
    private let dbName = "lana.sqlite"

    private init() {
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    // MARK: - Saved Words

    func saveWord(_ word: Word) {
        let query = "INSERT OR REPLACE INTO saved_words (id, word, translation, added_at) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: word.id)
            bindText(statement, index: 2, value: word.word)
            bindText(statement, index: 3, value: word.translation)
            sqlite3_bind_double(statement, 4, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        initSRSCard(wordId: word.id)
    }

    func removeWord(id: String) {
        let q1 = "DELETE FROM saved_words WHERE id = ?;"
        var s1: OpaquePointer?
        if sqlite3_prepare_v2(db, q1, -1, &s1, nil) == SQLITE_OK {
            bindText(s1, index: 1, value: id)
            sqlite3_step(s1)
        }
        sqlite3_finalize(s1)

        let q2 = "DELETE FROM word_reviews WHERE word_id = ?;"
        var s2: OpaquePointer?
        if sqlite3_prepare_v2(db, q2, -1, &s2, nil) == SQLITE_OK {
            bindText(s2, index: 1, value: id)
            sqlite3_step(s2)
        }
        sqlite3_finalize(s2)
    }

    func fetchSavedWords() -> [SavedWord] {
        let query = "SELECT id, word, translation, added_at FROM saved_words ORDER BY added_at DESC;"
        var statement: OpaquePointer?
        var result: [SavedWord] = []
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let word = String(cString: sqlite3_column_text(statement, 1))
                let translation = String(cString: sqlite3_column_text(statement, 2))
                let timestamp = sqlite3_column_double(statement, 3)
                result.append(SavedWord(id: id, word: word, translation: translation, addedAt: Date(timeIntervalSince1970: timestamp)))
            }
        }
        sqlite3_finalize(statement)
        return result
    }

    // MARK: - Quiz Results

    func saveQuizResult(_ result: QuizResult) {
        let query = "INSERT INTO quiz_results (quiz_id, correct_count, total_count, created_at) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: result.quizId)
            sqlite3_bind_int(statement, 2, Int32(result.correctCount))
            sqlite3_bind_int(statement, 3, Int32(result.totalCount))
            sqlite3_bind_double(statement, 4, result.date.timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        updateStreakIfNeeded()
        recordDailyActivity()
    }

    // MARK: - Progress

    func fetchProgress() -> ProgressStats {
        let quizzesTaken = fetchCount(query: "SELECT COUNT(*) FROM quiz_results;")
        let correctAnswers = fetchCount(query: "SELECT COALESCE(SUM(correct_count), 0) FROM quiz_results;")
        let learnedWords = fetchCount(query: "SELECT COUNT(*) FROM saved_words;")
        let currentStreak = fetchUserStat(key: "current_streak") ?? 0
        return ProgressStats(quizzesTaken: quizzesTaken, correctAnswers: correctAnswers, learnedWords: learnedWords, currentStreak: currentStreak)
    }

    // MARK: - XP System

    func addXP(_ amount: Int) {
        let current = fetchUserStat(key: "total_xp") ?? 0
        saveUserStat(key: "total_xp", value: current + amount)
        logXP(amount)
        recordDailyActivity()
    }

    private func logXP(_ amount: Int) {
        let query = "INSERT INTO xp_log (amount, earned_at) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(amount))
            sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchWeeklyXP() -> Int {
        let cal = Calendar(identifier: .iso8601)
        let monday = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let mondayTS = monday.timeIntervalSince1970
        return fetchCount(query: "SELECT COALESCE(SUM(amount), 0) FROM xp_log WHERE earned_at >= \(mondayTS);")
    }

    /// Returns XP earned each day for the last `days` days.
    /// Index 0 = oldest day, last index = today.
    func fetchDailyXP(days: Int = 7) -> [Int] {
        let now    = Date()
        let startTS = now.timeIntervalSince1970 - Double(days - 1) * 86400
        let query  = """
            SELECT CAST(earned_at / 86400 AS INTEGER) as bucket,
                   COALESCE(SUM(amount), 0)
            FROM xp_log WHERE earned_at >= \(startTS)
            GROUP BY bucket ORDER BY bucket ASC;
            """
        var statement: OpaquePointer?
        var bucketMap: [Int: Int] = [:]
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let bucket = Int(sqlite3_column_int64(statement, 0))
                let xp     = Int(sqlite3_column_int(statement, 1))
                bucketMap[bucket] = xp
            }
        }
        sqlite3_finalize(statement)
        let todayBucket = Int(now.timeIntervalSince1970 / 86400)
        return (0..<days).map { offset in
            bucketMap[todayBucket - (days - 1 - offset)] ?? 0
        }
    }

    func fetchTotalXP() -> Int {
        return fetchUserStat(key: "total_xp") ?? 0
    }

    func addXPOnce(key: String, amount: Int) -> Bool {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        let storedDay = fetchUserStat(key: "xp_day_\(key)") ?? -1
        guard storedDay != today else { return false }
        saveUserStat(key: "xp_day_\(key)", value: today)
        addXP(amount)
        return true
    }

    // MARK: - Level System

    static func level(for xp: Int) -> LevelInfo {
        let levels: [(Int, String, String)] = [
            (0,    "Newcomer",     "leaf.fill"),
            (100,  "Beginner",     "book.closed.fill"),
            (300,  "Explorer",     "magnifyingglass"),
            (600,  "Learner",      "pencil"),
            (1000, "Intermediate", "star.fill"),
            (1500, "Advanced",     "bolt.circle.fill"),
            (2500, "Expert",       "trophy.fill"),
            (4000, "Master",       "diamond.fill")
        ]
        var currentLevel = 0
        for (i, entry) in levels.enumerated() {
            if xp >= entry.0 { currentLevel = i }
        }
        let (minXP, name, icon) = levels[currentLevel]
        let maxXP = currentLevel + 1 < levels.count ? levels[currentLevel + 1].0 : minXP + 1000
        return LevelInfo(
            level: currentLevel + 1,
            name: name,
            icon: icon,
            currentXP: xp,
            minXP: minXP,
            maxXP: maxXP
        )
    }

    // MARK: - Lesson Completions

    func markLessonComplete(_ lessonId: String) {
        let query = "INSERT OR IGNORE INTO lesson_completions (lesson_id, completed_at) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: lessonId)
            sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func isLessonComplete(_ lessonId: String) -> Bool {
        let query = "SELECT COUNT(*) FROM lesson_completions WHERE lesson_id = ?;"
        var statement: OpaquePointer?
        var count = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: lessonId)
            if sqlite3_step(statement) == SQLITE_ROW { count = Int(sqlite3_column_int(statement, 0)) }
        }
        sqlite3_finalize(statement)
        return count > 0
    }

    func fetchCompletedLessonIds() -> Set<String> {
        let query = "SELECT lesson_id FROM lesson_completions;"
        var statement: OpaquePointer?
        var ids = Set<String>()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                ids.insert(String(cString: sqlite3_column_text(statement, 0)))
            }
        }
        sqlite3_finalize(statement)
        return ids
    }

    func fetchCompletedLessonCount() -> Int {
        return fetchCount(query: "SELECT COUNT(*) FROM lesson_completions;")
    }

    // MARK: - Achievements

    func unlockAchievement(_ id: String) {
        let query = "INSERT OR IGNORE INTO achievements_unlocked (achievement_id, unlocked_at) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: id)
            sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func isAchievementUnlocked(_ id: String) -> Bool {
        return fetchCount(query: "SELECT COUNT(*) FROM achievements_unlocked WHERE achievement_id = '\(id)';") > 0
    }

    func fetchUnlockedAchievementIds() -> Set<String> {
        let query = "SELECT achievement_id FROM achievements_unlocked;"
        var statement: OpaquePointer?
        var ids = Set<String>()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                ids.insert(String(cString: sqlite3_column_text(statement, 0)))
            }
        }
        sqlite3_finalize(statement)
        return ids
    }

    // MARK: - Daily Activity (streak calendar)

    func recordDailyActivity() {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        execute(query: "INSERT OR IGNORE INTO daily_activity (date_key) VALUES (\(today));")
    }

    /// Returns set of day-keys (timestamp/86400) for the last `n` days where user was active.
    func fetchActivityDays(last n: Int) -> Set<Int> {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        let start = today - n + 1
        let query = "SELECT date_key FROM daily_activity WHERE date_key >= \(start);"
        var statement: OpaquePointer?
        var days = Set<Int>()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                days.insert(Int(sqlite3_column_int(statement, 0)))
            }
        }
        sqlite3_finalize(statement)
        return days
    }

    // MARK: - SRS (Spaced Repetition)

    private func initSRSCard(wordId: String) {
        let dueNow = Date().timeIntervalSince1970
        let query = """
        INSERT OR IGNORE INTO word_reviews (word_id, ease_factor, interval_days, due_date, repetitions)
        VALUES (?, 2.5, 1, ?, 0);
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: wordId)
            sqlite3_bind_double(statement, 2, dueNow)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func recordSRSReview(wordId: String, quality: Int) {
        guard let card = fetchSRSCard(wordId: wordId) else { return }

        var repetitions = card.repetitions
        var easeFactor = card.easeFactor
        var intervalDays = card.intervalDays

        if quality >= 3 {
            switch repetitions {
            case 0: intervalDays = 1
            case 1: intervalDays = 6
            default: intervalDays = Int(round(Double(intervalDays) * easeFactor))
            }
            repetitions += 1
            easeFactor += 0.1 - Double(5 - quality) * (0.08 + Double(5 - quality) * 0.02)
            if easeFactor < 1.3 { easeFactor = 1.3 }
        } else {
            repetitions = 0
            intervalDays = 1
        }

        let dueDate = Date().timeIntervalSince1970 + Double(intervalDays) * 86_400

        let query = """
        INSERT OR REPLACE INTO word_reviews (word_id, ease_factor, interval_days, due_date, repetitions)
        VALUES (?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: wordId)
            sqlite3_bind_double(statement, 2, easeFactor)
            sqlite3_bind_int(statement, 3, Int32(intervalDays))
            sqlite3_bind_double(statement, 4, dueDate)
            sqlite3_bind_int(statement, 5, Int32(repetitions))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchDueWordIds() -> Set<String> {
        let now = Date().timeIntervalSince1970
        let query = "SELECT word_id FROM word_reviews WHERE due_date <= ?;"
        var statement: OpaquePointer?
        var ids = Set<String>()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_double(statement, 1, now)
            while sqlite3_step(statement) == SQLITE_ROW {
                ids.insert(String(cString: sqlite3_column_text(statement, 0)))
            }
        }
        sqlite3_finalize(statement)
        return ids
    }

    func daysUntilReview(wordId: String) -> Int {
        guard let card = fetchSRSCard(wordId: wordId) else { return 0 }
        let diff = card.dueDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        return max(0, Int(diff / 86_400))
    }

    // MARK: - Story Progress

    func saveStoryProgress(storyId: String, paragraphIndex: Int) {
        let query = "INSERT OR REPLACE INTO story_progress (story_id, paragraph_index, completed) VALUES (?, ?, 0);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: storyId)
            sqlite3_bind_int(statement, 2, Int32(paragraphIndex))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func markStoryComplete(_ storyId: String) {
        let query = "INSERT OR REPLACE INTO story_progress (story_id, paragraph_index, completed) VALUES (?, 9999, 1);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: storyId)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func isStoryComplete(_ storyId: String) -> Bool {
        let query = "SELECT completed FROM story_progress WHERE story_id = ?;"
        var statement: OpaquePointer?
        var result = false
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: storyId)
            if sqlite3_step(statement) == SQLITE_ROW { result = sqlite3_column_int(statement, 0) == 1 }
        }
        sqlite3_finalize(statement)
        return result
    }

    func fetchCompletedStoryIds() -> Set<String> {
        let query = "SELECT story_id FROM story_progress WHERE completed = 1;"
        var statement: OpaquePointer?
        var ids = Set<String>()
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                ids.insert(String(cString: sqlite3_column_text(statement, 0)))
            }
        }
        sqlite3_finalize(statement)
        return ids
    }

    func fetchStoryParagraphIndex(storyId: String) -> Int {
        let query = "SELECT paragraph_index FROM story_progress WHERE story_id = ?;"
        var statement: OpaquePointer?
        var idx = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: storyId)
            if sqlite3_step(statement) == SQLITE_ROW { idx = Int(sqlite3_column_int(statement, 0)) }
        }
        sqlite3_finalize(statement)
        return idx
    }

    // MARK: - Mistakes

    func saveMistake(questionText: String, correctAnswer: String, userAnswer: String, source: String) {
        let insert = """
        INSERT INTO mistakes (question_text, correct_answer, user_answer, source, created_at)
        VALUES (?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, insert, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: questionText)
            bindText(statement, index: 2, value: correctAnswer)
            bindText(statement, index: 3, value: userAnswer)
            bindText(statement, index: 4, value: source)
            sqlite3_bind_double(statement, 5, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        // Cap at 50 rows — delete oldest if exceeded
        execute(query: "DELETE FROM mistakes WHERE id NOT IN (SELECT id FROM mistakes ORDER BY created_at DESC LIMIT 50);")
    }

    func fetchMistakes() -> [MistakeItem] {
        let query = "SELECT id, question_text, correct_answer, user_answer, source, created_at FROM mistakes ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var result: [MistakeItem] = []
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(statement, 0))
                let questionText = String(cString: sqlite3_column_text(statement, 1))
                let correctAnswer = String(cString: sqlite3_column_text(statement, 2))
                let userAnswer = String(cString: sqlite3_column_text(statement, 3))
                let source = String(cString: sqlite3_column_text(statement, 4))
                let timestamp = sqlite3_column_double(statement, 5)
                result.append(MistakeItem(
                    id: id,
                    questionText: questionText,
                    correctAnswer: correctAnswer,
                    userAnswer: userAnswer,
                    source: source,
                    createdAt: Date(timeIntervalSince1970: timestamp)
                ))
            }
        }
        sqlite3_finalize(statement)
        return result
    }

    func deleteMistake(id: Int) {
        let query = "DELETE FROM mistakes WHERE id = ?;"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func clearAllMistakes() {
        execute(query: "DELETE FROM mistakes;")
    }

    // MARK: - Word Repetitions

    func fetchWordRepetitions(wordId: String) -> Int {
        let query = "SELECT repetitions FROM word_reviews WHERE word_id = ?;"
        var statement: OpaquePointer?
        var reps = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: wordId)
            if sqlite3_step(statement) == SQLITE_ROW {
                reps = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return reps
    }

    // MARK: - Custom Words

    func saveCustomWord(word: String, translation: String) {
        let id = "custom_\(UUID().uuidString)"
        let query = "INSERT INTO saved_words (id, word, translation, added_at) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: id)
            bindText(statement, index: 2, value: word)
            bindText(statement, index: 3, value: translation)
            sqlite3_bind_double(statement, 4, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
        initSRSCard(wordId: id)
    }

    // MARK: - Private Helpers

    private struct SRSCard {
        let easeFactor: Double
        let intervalDays: Int
        let dueDate: Date
        let repetitions: Int
    }

    private func fetchSRSCard(wordId: String) -> SRSCard? {
        let query = "SELECT ease_factor, interval_days, due_date, repetitions FROM word_reviews WHERE word_id = ?;"
        var statement: OpaquePointer?
        var card: SRSCard?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: wordId)
            if sqlite3_step(statement) == SQLITE_ROW {
                let ef = sqlite3_column_double(statement, 0)
                let iv = Int(sqlite3_column_int(statement, 1))
                let dd = Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))
                let rp = Int(sqlite3_column_int(statement, 3))
                card = SRSCard(easeFactor: ef, intervalDays: iv, dueDate: dd, repetitions: rp)
            }
        }
        sqlite3_finalize(statement)
        return card
    }

    private func openDatabase() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let dbURL = url.appendingPathComponent(dbName)
        sqlite3_open(dbURL.path, &db)
    }

    private func createTables() {
        let createSavedWords = """
        CREATE TABLE IF NOT EXISTS saved_words (
            id TEXT PRIMARY KEY,
            word TEXT NOT NULL,
            translation TEXT NOT NULL,
            added_at REAL NOT NULL
        );
        """
        let createQuizResults = """
        CREATE TABLE IF NOT EXISTS quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            quiz_id TEXT NOT NULL,
            correct_count INTEGER NOT NULL,
            total_count INTEGER NOT NULL,
            created_at REAL NOT NULL
        );
        """
        let createUserStats = """
        CREATE TABLE IF NOT EXISTS user_stats (
            key TEXT PRIMARY KEY,
            value INTEGER NOT NULL
        );
        """
        let createWordReviews = """
        CREATE TABLE IF NOT EXISTS word_reviews (
            word_id TEXT PRIMARY KEY,
            ease_factor REAL NOT NULL DEFAULT 2.5,
            interval_days INTEGER NOT NULL DEFAULT 1,
            due_date REAL NOT NULL,
            repetitions INTEGER NOT NULL DEFAULT 0
        );
        """
        let createLessonCompletions = """
        CREATE TABLE IF NOT EXISTS lesson_completions (
            lesson_id TEXT PRIMARY KEY,
            completed_at REAL NOT NULL
        );
        """
        let createAchievements = """
        CREATE TABLE IF NOT EXISTS achievements_unlocked (
            achievement_id TEXT PRIMARY KEY,
            unlocked_at REAL NOT NULL
        );
        """
        let createDailyActivity = """
        CREATE TABLE IF NOT EXISTS daily_activity (
            date_key INTEGER PRIMARY KEY
        );
        """
        let createXPLog = """
        CREATE TABLE IF NOT EXISTS xp_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            amount INTEGER NOT NULL,
            earned_at REAL NOT NULL
        );
        """
        let createStoryProgress = """
        CREATE TABLE IF NOT EXISTS story_progress (
            story_id TEXT PRIMARY KEY,
            paragraph_index INTEGER NOT NULL DEFAULT 0,
            completed INTEGER NOT NULL DEFAULT 0
        );
        """
        let createMistakes = """
        CREATE TABLE IF NOT EXISTS mistakes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question_text TEXT NOT NULL,
            correct_answer TEXT NOT NULL,
            user_answer TEXT NOT NULL,
            source TEXT NOT NULL,
            created_at REAL NOT NULL
        );
        """
        let createQuizStageResults = """
        CREATE TABLE IF NOT EXISTS quiz_stage_results (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            stage_id      TEXT NOT NULL,
            stars         INTEGER NOT NULL,
            correct_count INTEGER NOT NULL,
            total_count   INTEGER NOT NULL,
            completed_at  REAL NOT NULL
        );
        """
        execute(query: createSavedWords)
        execute(query: createQuizResults)
        execute(query: createUserStats)
        execute(query: createWordReviews)
        execute(query: createLessonCompletions)
        execute(query: createAchievements)
        execute(query: createDailyActivity)
        execute(query: createXPLog)
        execute(query: createStoryProgress)
        execute(query: createMistakes)
        execute(query: createQuizStageResults)
    }

    // MARK: - Quiz Stage Results

    func saveStageResult(stageId: String, stars: Int, correct: Int, total: Int) {
        let query = "INSERT INTO quiz_stage_results (stage_id, stars, correct_count, total_count, completed_at) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: stageId)
            sqlite3_bind_int(statement, 2, Int32(stars))
            sqlite3_bind_int(statement, 3, Int32(correct))
            sqlite3_bind_int(statement, 4, Int32(total))
            sqlite3_bind_double(statement, 5, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    func fetchBestStars(stageId: String) -> Int {
        let query = "SELECT COALESCE(MAX(stars), 0) FROM quiz_stage_results WHERE stage_id = ?;"
        var statement: OpaquePointer?
        var value = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: stageId)
            if sqlite3_step(statement) == SQLITE_ROW {
                value = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return value
    }

    func fetchAllBestStars() -> [String: Int] {
        let query = "SELECT stage_id, MAX(stars) FROM quiz_stage_results GROUP BY stage_id;"
        var statement: OpaquePointer?
        var result: [String: Int] = [:]
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = String(cString: sqlite3_column_text(statement, 0))
                let stars = Int(sqlite3_column_int(statement, 1))
                result[id] = stars
            }
        }
        sqlite3_finalize(statement)
        return result
    }

    private func execute(query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    private func fetchCount(query: String) -> Int {
        var statement: OpaquePointer?
        var value = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_ROW {
                value = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return value
    }

    private func updateStreakIfNeeded() {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        let lastActive = fetchUserStat(key: "last_active_day") ?? 0
        let currentStreak = fetchUserStat(key: "current_streak") ?? 0
        if lastActive == today { return }
        let newStreak = (lastActive == today - 1) ? (currentStreak + 1) : 1
        saveUserStat(key: "current_streak", value: newStreak)
        saveUserStat(key: "last_active_day", value: today)
    }

    func fetchTodayActivityCount() -> Int {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        return fetchCount(query: "SELECT COUNT(*) FROM user_stats WHERE key LIKE 'xp_day_%' AND value = \(today);")
    }

    func fetchUserStat(key: String) -> Int? {
        let query = "SELECT value FROM user_stats WHERE key = ?;"
        var statement: OpaquePointer?
        var value: Int?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: key)
            if sqlite3_step(statement) == SQLITE_ROW {
                value = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return value
    }

    /// Public write accessor used by QuestService and streak-freeze logic.
    func setUserStat(key: String, value: Int) {
        saveUserStat(key: key, value: value)
    }

    private func saveUserStat(key: String, value: Int) {
        let query = "INSERT OR REPLACE INTO user_stats (key, value) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            bindText(statement, index: 1, value: key)
            sqlite3_bind_int(statement, 2, Int32(value))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }

    private func bindText(_ statement: OpaquePointer?, index: Int32, value: String) {
        sqlite3_bind_text(statement, index, (value as NSString).utf8String, -1, nil)
    }

    // MARK: - Streak Freeze

    func fetchStreakFreezeCount() -> Int {
        return fetchUserStat(key: "streak_freeze_count") ?? 0
    }

    /// Returns true when the user has an active (purchased) streak freeze shield.
    func hasStreakFreeze() -> Bool {
        return (fetchUserStat(key: "streak_freeze_active") ?? 0) == 1
    }

    /// Purchases a streak freeze for 200 XP. Returns false when XP is insufficient.
    @discardableResult
    func activateStreakFreeze() -> Bool {
        let current = fetchUserStat(key: "total_xp") ?? 0
        guard current >= 200 else { return false }
        saveUserStat(key: "total_xp", value: current - 200)
        saveUserStat(key: "streak_freeze_active", value: 1)
        return true
    }

    /// Consumes the active streak freeze (called automatically when a streak would otherwise break).
    func consumeStreakFreeze() {
        saveUserStat(key: "streak_freeze_active", value: 0)
    }

    /// Uses one streak freeze if available. Inserts yesterday's day-key into
    /// daily_activity so the streak calculation treats yesterday as active.
    /// Returns true when a freeze was consumed.
    @discardableResult
    func useStreakFreeze() -> Bool {
        let count = fetchStreakFreezeCount()
        guard count > 0 else { return false }
        setUserStat(key: "streak_freeze_count", value: count - 1)
        let yesterdayKey = Int(Date().timeIntervalSince1970 / 86_400) - 1
        execute(query: "INSERT OR IGNORE INTO daily_activity (date_key) VALUES (\(yesterdayKey));")
        return true
    }

    /// Called automatically whenever the user crosses a 100-XP milestone.
    /// Caps at 3 freezes held at once.
    func earnStreakFreeze() {
        let count = fetchStreakFreezeCount()
        if count < 3 {
            setUserStat(key: "streak_freeze_count", value: count + 1)
        }
    }
}

// MARK: - Level Info

struct LevelInfo {
    let level: Int
    let name: String
    let icon: String   // SF Symbol name
    let currentXP: Int
    let minXP: Int
    let maxXP: Int

    var progress: Double {
        let range = Double(maxXP - minXP)
        guard range > 0 else { return 1.0 }
        return min(1.0, Double(currentXP - minXP) / range)
    }

    var xpToNext: Int { max(0, maxXP - currentXP) }
}

// MARK: - CEFR Level

enum CEFRLevel: String {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
    case b2 = "B2"
    case c1 = "C1"
    case c2 = "C2"

    static func level(for xp: Int) -> CEFRLevel {
        switch xp {
        case 0..<300:   return .a1
        case 300..<600: return .a2
        case 600..<1000: return .b1
        case 1000..<1500: return .b2
        case 1500..<2500: return .c1
        default:         return .c2
        }
    }

    var color: String {
        switch self {
        case .a1: return "#A8D5A2"
        case .a2: return "#B5D8F7"
        case .b1: return "#F7E0A2"
        case .b2: return "#F7C5A2"
        case .c1: return "#D4A8F7"
        case .c2: return "#F7A8C4"
        }
    }

    var description: String {
        switch self {
        case .a1: return "Beginner"
        case .a2: return "Elementary"
        case .b1: return "Intermediate"
        case .b2: return "Upper-Intermediate"
        case .c1: return "Advanced"
        case .c2: return "Proficient"
        }
    }
}
