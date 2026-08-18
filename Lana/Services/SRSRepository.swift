import Foundation
import SQLite3

final class SRSRepository {
    static let shared = SRSRepository()
    
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
    
    private struct SRSCard {
        let easeFactor: Double
        let intervalDays: Int
        let dueDate: Date
        let repetitions: Int
    }
    
    func initSRSCard(wordId: String) {
        let dueNow = Date().timeIntervalSince1970
        let query = """
        INSERT OR IGNORE INTO word_reviews (word_id, ease_factor, interval_days, due_date, repetitions)
        VALUES (?, 2.5, 1, ?, 0);
        """
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (wordId as NSString).utf8String, -1, nil)
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
            sqlite3_bind_text(statement, 1, (wordId as NSString).utf8String, -1, nil)
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
    
    func fetchWordRepetitions(wordId: String) -> Int {
        let query = "SELECT repetitions FROM word_reviews WHERE word_id = ?;"
        var statement: OpaquePointer?
        var reps = 0
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (wordId as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                reps = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return reps
    }
    
    private func fetchSRSCard(wordId: String) -> SRSCard? {
        let query = "SELECT ease_factor, interval_days, due_date, repetitions FROM word_reviews WHERE word_id = ?;"
        var statement: OpaquePointer?
        var card: SRSCard?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (wordId as NSString).utf8String, -1, nil)
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
}
