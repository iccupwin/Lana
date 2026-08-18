import Foundation
import SQLite3

final class ProgressRepository {
    static let shared = ProgressRepository()
    
    private var db: OpaquePointer?
    private let dbName = "lana.sqlite"
    
    private init() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let dbURL = url.appendingPathComponent(dbName)
        sqlite3_open(dbURL.path, &db)
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    struct ProgressStats {
        let quizzesTaken: Int
        let correctAnswers: Int
        let learnedWords: Int
        let currentStreak: Int
    }
    
    func fetchProgress() -> ProgressStats {
        let quizzesTaken = fetchCount(query: "SELECT COUNT(*) FROM quiz_results;")
        let correctAnswers = fetchCount(query: "SELECT COALESCE(SUM(correct_count), 0) FROM quiz_results;")
        let learnedWords = fetchCount(query: "SELECT COUNT(*) FROM saved_words;")
        let currentStreak = UserRepository.shared.fetchCurrentStreak()
        return ProgressStats(
            quizzesTaken: quizzesTaken,
            correctAnswers: correctAnswers,
            learnedWords: learnedWords,
            currentStreak: currentStreak
        )
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
    
    func fetchBestStars(stageId: String) -> Int {
        let query = "SELECT COALESCE(MAX(stars), 0) FROM quiz_stage_results WHERE stage_id = ?;"
        var statement: OpaquePointer?
        var value = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (stageId as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                value = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return value
    }
    
    func saveStageResult(stageId: String, stars: Int, correct: Int, total: Int) {
        let query = "INSERT INTO quiz_stage_results (stage_id, stars, correct_count, total_count, completed_at) VALUES (?, ?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (stageId as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(stars))
            sqlite3_bind_int(statement, 3, Int32(correct))
            sqlite3_bind_int(statement, 4, Int32(total))
            sqlite3_bind_double(statement, 5, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    func saveQuizResult(_ result: QuizResult) {
        let query = "INSERT INTO quiz_results (quiz_id, correct_count, total_count, created_at) VALUES (?, ?, ?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (result.quizId as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(result.correctCount))
            sqlite3_bind_int(statement, 3, Int32(result.totalCount))
            sqlite3_bind_double(statement, 4, result.date.timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    func markLessonComplete(_ lessonId: String) {
        let query = "INSERT OR IGNORE INTO lesson_completions (lesson_id, completed_at) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (lessonId as NSString).utf8String, -1, nil)
            sqlite3_bind_double(statement, 2, Date().timeIntervalSince1970)
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
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
    
    func recordDailyActivity() {
        let today = Int(Date().timeIntervalSince1970 / 86_400)
        execute(query: "INSERT OR IGNORE INTO daily_activity (date_key) VALUES (\(today));")
    }
    
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
    
    func fetchWeeklyXP() -> Int {
        let cal = Calendar(identifier: .iso8601)
        let monday = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()
        let mondayTS = monday.timeIntervalSince1970
        return fetchCount(query: "SELECT COALESCE(SUM(amount), 0) FROM xp_log WHERE earned_at >= \(mondayTS);")
    }
    
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
    
    private func execute(query: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
}
