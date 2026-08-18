import Foundation
import Combine
import UIKit

struct TypingQuestion: Identifiable {
    let id = UUID()
    let sentence: String    // sentence with "___"
    let answer: String      // correct word
    let translation: String
}

final class TypingPracticeViewModel: ObservableObject {
    @Published var questions: [TypingQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var typedText: String = ""
    @Published var isChecked: Bool = false
    @Published var isCorrect: Bool = false
    @Published var score: Int = 0
    @Published var isFinished: Bool = false

    init() { buildQuestions() }

    var current: TypingQuestion? { questions.isEmpty ? nil : questions[currentIndex] }
    var progress: Double { questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count) }

    func checkAnswer() {
        guard let q = current, !isChecked else { return }
        isChecked = true
        let userAns = typedText.trimmingCharacters(in: .whitespaces).lowercased()
        let correct = q.answer.lowercased()
        // Allow 1 typo via Levenshtein distance
        isCorrect = userAns == correct || levenshtein(userAns, correct) <= 1
        if isCorrect {
            score += 1
            HapticService.shared.notify(.success)
        } else {
            HapticService.shared.notify(.error)
        }
    }

    func next() {
        HapticService.shared.impact(.light)
        if currentIndex + 1 >= questions.count {
            isFinished = true
        } else {
            currentIndex += 1
            typedText = ""
            isChecked = false
            isCorrect = false
        }
    }

    // Simple Levenshtein distance
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        guard !a.isEmpty else { return b.count }
        guard !b.isEmpty else { return a.count }
        var dp = Array(0...b.count)
        for i in 1...a.count {
            var prev = dp
            dp[0] = i
            for j in 1...b.count {
                if a[i - 1] == b[j - 1] {
                    dp[j] = prev[j - 1]
                } else {
                    dp[j] = 1 + min(prev[j], dp[j - 1], prev[j - 1])
                }
            }
        }
        return dp[b.count]
    }

    private func buildQuestions() {
        let vocab: [(String, String, String)] = [
            ("symptom",      "симптом",                       "A headache is a common ___ of stress."),
            ("prescription", "рецепт",                        "The doctor gave me a ___ for antibiotics."),
            ("appointment",  "приём",                         "I have a doctor's ___ at 3 p.m."),
            ("episode",      "серия",                         "I watched three ___s in a row."),
            ("ingredient",   "ингредиент",                    "The key ___ is fresh basil."),
            ("deadline",     "дедлайн",                       "The ___ for the project is Friday."),
            ("promotion",    "повышение",                     "She received a ___ after six months."),
            ("itinerary",    "маршрут",                       "Our ___ includes three cities."),
            ("landmark",     "достопримечательность",         "Big Ben is London's most famous ___."),
            ("fluent",       "свободный",                     "She is ___ in three languages."),
            ("aspiration",   "стремление",                    "Her ___ is to become a doctor."),
            ("feedback",     "обратная связь",                "Could you give me ___ on my presentation?"),
            ("colleague",    "коллега",                       "My ___ helped me prepare the report."),
            ("departure",    "вылет",                         "The ___ is at 6 a.m."),
            ("milestone",    "этап",                          "Graduating was a big ___ for me."),
        ]
        questions = vocab.shuffled().prefix(10).map { item in
            TypingQuestion(sentence: item.2, answer: item.0, translation: item.1)
        }
    }
}
