import Foundation

struct ListeningExercise: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let audioFileName: String?
    let transcript: String
    let questions: [QuizQuestion]
    let cultureNote: String?    // R10-E: cultural context note
}
