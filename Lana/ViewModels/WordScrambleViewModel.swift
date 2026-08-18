import Foundation
import Combine

final class WordScrambleViewModel: ObservableObject {
    @Published var currentWord: SavedWord?
    @Published var scrambledLetters: [String] = []
    @Published var userAnswer: [String] = []
    @Published var isCorrect: Bool? = nil
    @Published var score: Int = 0
    @Published var round: Int = 0
    @Published var isFinished: Bool = false

    private var words: [SavedWord] = []
    private let totalRounds = 8
    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        words = sqliteService.fetchSavedWords().filter { $0.word.count <= 10 }
        nextWord()
    }

    var progress: Double { Double(round) / Double(totalRounds) }
    var hasWords: Bool { !words.isEmpty }

    func nextWord() {
        guard round < totalRounds, !words.isEmpty else { isFinished = true; return }
        isCorrect = nil
        userAnswer = []
        let word = words.randomElement()!
        currentWord = word
        scrambledLetters = word.word.map { String($0) }.shuffled()
        // Make sure it's actually scrambled
        while scrambledLetters == word.word.map({ String($0) }) {
            scrambledLetters.shuffle()
        }
    }

    func tapLetter(_ letter: String, at index: Int) {
        guard isCorrect == nil else { return }
        userAnswer.append(letter)
        scrambledLetters.remove(at: index)
        checkAnswer()
    }

    func removeLetter(at index: Int) {
        guard isCorrect == nil else { return }
        scrambledLetters.append(userAnswer[index])
        userAnswer.remove(at: index)
    }

    private func checkAnswer() {
        guard let word = currentWord else { return }
        let answer = userAnswer.joined()
        if answer.count == word.word.count {
            let correct = answer.lowercased() == word.word.lowercased()
            isCorrect = correct
            if correct { score += 1 }
            sqliteService.recordSRSReview(wordId: word.id, quality: correct ? 5 : 1)
            round += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) { [weak self] in
                self?.nextWord()
            }
        }
    }
}
