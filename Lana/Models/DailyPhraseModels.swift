import Foundation

struct DailyPhrase: Identifiable, Codable {
    let id: String
    let dayIndex: Int
    let phrase: String
    let translation: String
    let exampleSentence: String
    let exampleTranslation: String
    let type: String          // "idiom" | "phrasal_verb" | "expression"
    let difficulty: String    // "A2" | "B1" | "B2"
}
