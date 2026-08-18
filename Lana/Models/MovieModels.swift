import Foundation

struct MovieScene: Identifiable, Codable, Hashable {
    let id: String
    let movieTitle: String
    let sceneTitle: String
    let dialogue: String
    let translation: String
    let expressions: [Expression]
    let audioFileName: String?
    let cultureNote: String?    // R10-B: cultural context for Russian learners
}

struct Expression: Identifiable, Codable, Hashable {
    let id: String
    let phrase: String
    let meaning: String
}
