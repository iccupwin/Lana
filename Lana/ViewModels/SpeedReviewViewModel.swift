import Foundation
import Combine

final class SpeedReviewViewModel: ObservableObject {
    @Published var currentCard: SavedWord?
    @Published var choices: [String] = []
    @Published var selectedIndex: Int? = nil
    @Published var isCorrect: Bool? = nil
    @Published var timeRemaining: Double = 10.0
    @Published var score: Int = 0
    @Published var round: Int = 0
    @Published var isFinished: Bool = false

    private var words: [SavedWord] = []
    private var usedIds: [String] = []
    private var timerCancellable: AnyCancellable?
    private let totalRounds = 10
    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        words = sqliteService.fetchSavedWords()
        nextCard()
    }

    var progress: Double { Double(round) / Double(totalRounds) }
    var canStart: Bool { words.count >= 4 }

    func nextCard() {
        guard round < totalRounds, words.count >= 4 else {
            isFinished = true
            return
        }
        selectedIndex = nil
        isCorrect = nil
        timeRemaining = 10.0

        let remaining = words.filter { !usedIds.contains($0.id) }
        let pool = remaining.isEmpty ? words : remaining
        let correct = pool.randomElement()!
        usedIds.append(correct.id)
        currentCard = correct

        var wrongWords = words.filter { $0.id != correct.id }.shuffled().prefix(3)
        var opts = wrongWords.map { $0.translation } + [correct.translation]
        opts.shuffle()
        choices = opts

        startTimer()
    }

    func select(index: Int) {
        guard selectedIndex == nil, let card = currentCard else { return }
        timerCancellable?.cancel()
        selectedIndex = index
        let correct = choices[index] == card.translation
        isCorrect = correct
        if correct { score += 1 }
        sqliteService.recordSRSReview(wordId: card.id, quality: correct ? 4 : 1)
        round += 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.nextCard()
        }
    }

    private func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                self.timeRemaining -= 0.1
                if self.timeRemaining <= 0 {
                    self.timerCancellable?.cancel()
                    self.isCorrect = false
                    if let card = self.currentCard {
                        self.sqliteService.recordSRSReview(wordId: card.id, quality: 0)
                    }
                    self.round += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.nextCard()
                    }
                }
            }
    }
}
