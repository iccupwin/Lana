import Foundation

struct Idiom: Identifiable, Codable {
    let id: String
    let phrase: String
    let meaning: String
    let example: String
    let translation: String
    let difficulty: String
    let category: String
}
