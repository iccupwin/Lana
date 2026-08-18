import Foundation

struct Quiz: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String
    let questions: [QuizQuestion]
}

struct QuizQuestion: Identifiable, Codable, Hashable {
    let id: String
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

struct QuizResult: Hashable {
    let quizId: String
    let correctCount: Int
    let totalCount: Int
    let date: Date
}
