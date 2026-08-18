import Foundation
import SQLite3

final class UserRepository {
    static let shared = UserRepository()
    
    private var db: OpaquePointer?
    private let dbName = "lana.sqlite"
    
    private init() {
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.db = nil
            return
        }
        let dbURL = url.appendingPathComponent(dbName)
        sqlite3_open(dbURL.path, &db)
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    func fetchUserStat(key: String) -> Int? {
        let query = "SELECT value FROM user_stats WHERE key = ?;"
        var statement: OpaquePointer?
        var value: Int?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
            if sqlite3_step(statement) == SQLITE_ROW {
                value = Int(sqlite3_column_int(statement, 0))
            }
        }
        sqlite3_finalize(statement)
        return value
    }
    
    func saveUserStat(key: String, value: Int) {
        let query = "INSERT OR REPLACE INTO user_stats (key, value) VALUES (?, ?);"
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (key as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 2, Int32(value))
            sqlite3_step(statement)
        }
        sqlite3_finalize(statement)
    }
    
    func fetchTotalXP() -> Int {
        return fetchUserStat(key: "total_xp") ?? 0
    }
    
    func addXP(_ amount: Int) {
        let current = fetchTotalXP()
        saveUserStat(key: "total_xp", value: current + amount)
    }
    
    func fetchCurrentStreak() -> Int {
        return fetchUserStat(key: "current_streak") ?? 0
    }
    
    func fetchStreakFreezeCount() -> Int {
        return fetchUserStat(key: "streak_freeze_count") ?? 0
    }
    
    func hasStreakFreeze() -> Bool {
        return (fetchUserStat(key: "streak_freeze_active") ?? 0) == 1
    }
    
    func activateStreakFreeze() -> Bool {
        let current = fetchTotalXP()
        guard current >= 200 else { return false }
        saveUserStat(key: "total_xp", value: current - 200)
        saveUserStat(key: "streak_freeze_active", value: 1)
        return true
    }
    
    func consumeStreakFreeze() {
        saveUserStat(key: "streak_freeze_active", value: 0)
    }
    
    func earnStreakFreeze() {
        let count = fetchStreakFreezeCount()
        if count < 3 {
            saveUserStat(key: "streak_freeze_count", value: count + 1)
        }
    }
}
