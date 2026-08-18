import Foundation

struct Word: Identifiable, Codable, Hashable {
    let id: String
    let word: String
    let phonetic: String
    let translation: String
    let example: String
    let dayIndex: Int
    let register: String?   // formal / neutral / informal / slang / british / american
    let cefr: String?       // A1 / A2 / B1 / B2 / C1 / C2
    let collocations: [String]?
}

struct SavedWord: Identifiable, Hashable {
    let id: String
    let word: String
    let translation: String
    let addedAt: Date
}

struct ProgressStats: Hashable {
    let quizzesTaken: Int
    let correctAnswers: Int
    let learnedWords: Int
    let currentStreak: Int
}
