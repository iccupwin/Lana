import Foundation
import Combine
import UIKit

struct FillBlankQuestion: Identifiable {
    let id = UUID()
    let sentence: String      // full sentence with "___" placeholder
    let answer: String        // correct word
    let options: [String]     // 4 choices including correct
    let translation: String   // translation hint
}

final class FillBlankViewModel: ObservableObject {
    @Published var questions: [FillBlankQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var selectedOption: String? = nil
    @Published var isAnswered: Bool = false
    @Published var score: Int = 0
    @Published var isFinished: Bool = false

    init() {
        buildQuestions()
    }

    var current: FillBlankQuestion? { questions.isEmpty ? nil : questions[currentIndex] }
    var progress: Double { questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count) }

    func select(_ option: String) {
        guard !isAnswered, let q = current else { return }
        selectedOption = option
        isAnswered = true
        if option == q.answer {
            score += 1
        } else {
            HeartsService.shared.useHeart()
            SQLiteService.shared.saveMistake(
                questionText: q.sentence,
                correctAnswer: q.answer,
                userAnswer: option,
                source: "Fill the Blank"
            )
        }
        HapticService.shared.notify(option == q.answer ? .success : .error)
    }

    func next() {
        HapticService.shared.impact(.light)
        if currentIndex + 1 >= questions.count {
            isFinished = true
        } else {
            currentIndex += 1
            selectedOption = nil
            isAnswered = false
        }
    }

    private func buildQuestions() {
        // All vocabulary items: (word, translation, example)
        let vocab: [(String, String, String)] = [
            ("symptom",      "симптом",                  "A headache is a common ___ of stress."),
            ("prescription", "рецепт",                   "The doctor gave me a ___ for antibiotics."),
            ("appointment",  "приём",                    "I have a doctor's ___ at 3 p.m."),
            ("treatment",    "лечение",                  "The ___ lasts for two weeks."),
            ("episode",      "серия",                    "I watched three ___s in a row."),
            ("sequel",       "продолжение",              "The ___ was even better than the original."),
            ("ingredient",   "ингредиент",               "The key ___ is fresh basil."),
            ("cuisine",      "кухня",                    "I love Italian ___."),
            ("deadline",     "дедлайн",                  "The ___ for the project is Friday."),
            ("promotion",    "повышение",                "She received a ___ after six months."),
            ("itinerary",    "маршрут",                  "Our ___ includes three cities."),
            ("landmark",     "достопримечательность",    "Big Ben is London's most famous ___."),
            ("occupation",   "профессия",                "My ___ is software engineering."),
            ("fluent",       "свободный",                "She is ___ in three languages."),
            ("passion",      "страсть",                  "___ is the key to mastering any skill."),
            ("aspiration",   "стремление",               "Her ___ is to become a doctor."),
            ("milestone",    "этап",                     "Graduating was a big ___ for me."),
            ("feedback",     "обратная связь",           "Could you give me ___ on my presentation?"),
            ("colleague",    "коллега",                  "My ___ helped me prepare the report."),
            ("departure",    "вылет",                    "The ___ is at 6 a.m."),
        ]

        // Build wrong answer pool
        let allWords = vocab.map { $0.0 }
        var qs: [FillBlankQuestion] = []
        for (word, translation, sentence) in vocab.shuffled().prefix(12) {
            let wrong = Array(allWords.filter { $0 != word }.shuffled().prefix(3))
            var options = wrong + [word]
            options.shuffle()
            qs.append(FillBlankQuestion(
                sentence: sentence,
                answer: word,
                options: options,
                translation: translation
            ))
        }
        questions = qs
    }
}
