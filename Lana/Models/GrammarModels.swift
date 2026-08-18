import Foundation

struct GrammarTopic: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let explanation: String
    let examples: [String]
    let miniQuiz: [QuizQuestion]
    let russianContrast: String?   // R3-A: explains the Russian learner's typical error
}
