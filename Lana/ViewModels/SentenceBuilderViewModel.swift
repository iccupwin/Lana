import Foundation
import Combine
import UIKit

// MARK: - Models

struct WordTile: Identifiable, Equatable {
    let id = UUID()
    let word: String
}

struct SentencePuzzle {
    let hint: String         // Russian translation shown to user
    let answer: [String]     // correct English word order
    let distractors: [String]
}

// MARK: - ViewModel

final class SentenceBuilderViewModel: ObservableObject {
    @Published var bank: [WordTile] = []
    @Published var placed: [WordTile] = []
    @Published var isAnswered: Bool = false
    @Published var isCorrect: Bool = false
    @Published var currentIndex: Int = 0
    @Published var score: Int = 0
    @Published var isFinished: Bool = false

    private let puzzles: [SentencePuzzle]

    var current: SentencePuzzle? {
        guard currentIndex < puzzles.count else { return nil }
        return puzzles[currentIndex]
    }
    var progress: Double { puzzles.isEmpty ? 0 : Double(currentIndex) / Double(puzzles.count) }
    var total: Int { puzzles.count }

    init() {
        puzzles = Self.buildPuzzles().shuffled()
        loadQuestion()
    }

    // MARK: Load

    func loadQuestion() {
        guard let puzzle = current else { return }
        let answerTiles = puzzle.answer.map { WordTile(word: $0) }
        let distractorTiles = puzzle.distractors.map { WordTile(word: $0) }
        bank = (answerTiles + distractorTiles).shuffled()
        placed = []
        isAnswered = false
        isCorrect = false
    }

    // MARK: Actions

    func place(_ tile: WordTile) {
        guard !isAnswered else { return }
        bank.removeAll { $0.id == tile.id }
        placed.append(tile)
        HapticService.shared.impact(.light)
    }

    func remove(_ tile: WordTile) {
        guard !isAnswered else { return }
        placed.removeAll { $0.id == tile.id }
        bank.append(tile)
        HapticService.shared.impact(.light)
    }

    func submit() {
        guard let puzzle = current, !placed.isEmpty else { return }
        let user = placed.map { $0.word.lowercased().trimmingCharacters(in: .punctuationCharacters) }
        let correct = puzzle.answer.map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
        isAnswered = true
        isCorrect = user == correct
        if isCorrect {
            score += 1
            HapticService.shared.notify(.success)
        } else {
            HeartsService.shared.useHeart()
            HapticService.shared.notify(.error)
        }
    }

    func next() {
        HapticService.shared.impact(.light)
        if currentIndex + 1 >= puzzles.count {
            isFinished = true
            SQLiteService.shared.addXP(score * 5)
        } else {
            currentIndex += 1
            loadQuestion()
        }
    }

    // MARK: Puzzles

    private static func buildPuzzles() -> [SentencePuzzle] {
        [
            SentencePuzzle(
                hint: "Я люблю учить новые слова каждый день.",
                answer: ["I", "love", "learning", "new", "words", "every", "day"],
                distractors: ["always", "much"]
            ),
            SentencePuzzle(
                hint: "Она очень хорошо говорит по-английски.",
                answer: ["She", "speaks", "English", "very", "well"],
                distractors: ["fluently", "good"]
            ),
            SentencePuzzle(
                hint: "Я изучаю английский уже два года.",
                answer: ["I", "have", "been", "studying", "English", "for", "two", "years"],
                distractors: ["learning", "since"]
            ),
            SentencePuzzle(
                hint: "Можете ли вы помочь мне с этим заданием?",
                answer: ["Can", "you", "help", "me", "with", "this", "task"],
                distractors: ["please", "work"]
            ),
            SentencePuzzle(
                hint: "У него приём у врача в три часа.",
                answer: ["He", "has", "a", "doctor's", "appointment", "at", "three"],
                distractors: ["today", "o'clock"]
            ),
            SentencePuzzle(
                hint: "Это был лучший фильм, который я когда-либо видел.",
                answer: ["That", "was", "the", "best", "movie", "I", "have", "ever", "seen"],
                distractors: ["watched", "great"]
            ),
            SentencePuzzle(
                hint: "Она мечтает путешествовать по всему миру.",
                answer: ["She", "dreams", "of", "travelling", "around", "the", "world"],
                distractors: ["visiting", "whole"]
            ),
            SentencePuzzle(
                hint: "Мне нужно закончить этот отчёт к пятнице.",
                answer: ["I", "need", "to", "finish", "this", "report", "by", "Friday"],
                distractors: ["complete", "before"]
            ),
            SentencePuzzle(
                hint: "Чем больше ты практикуешься, тем лучше становишься.",
                answer: ["The", "more", "you", "practise", "the", "better", "you", "become"],
                distractors: ["practice", "get"]
            ),
            SentencePuzzle(
                hint: "Не могли бы вы говорить немного медленнее?",
                answer: ["Could", "you", "please", "speak", "more", "slowly"],
                distractors: ["talk", "quietly"]
            ),
            SentencePuzzle(
                hint: "Я только что узнал значение этого слова.",
                answer: ["I", "just", "learned", "the", "meaning", "of", "this", "word"],
                distractors: ["found", "new"]
            ),
            SentencePuzzle(
                hint: "Они планируют переехать в другой город в следующем году.",
                answer: ["They", "plan", "to", "move", "to", "a", "different", "city", "next", "year"],
                distractors: ["town", "soon"]
            ),
        ]
    }
}
