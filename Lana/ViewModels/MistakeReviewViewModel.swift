import Foundation
import Combine
import UIKit

final class MistakeReviewViewModel: ObservableObject {
    @Published var mistakes: [MistakeItem] = []
    @Published var currentIndex: Int = 0
    @Published var selectedOption: String? = nil
    @Published var isAnswered: Bool = false
    @Published var isFinished: Bool = false
    @Published var correctCount: Int = 0

    private let sqliteService: SQLiteService
    var reviewItems: [MistakeItem] = []  // shuffled subset

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        loadMistakes()
    }

    var current: MistakeItem? { reviewItems.isEmpty ? nil : reviewItems[currentIndex] }
    var total: Int { reviewItems.count }

    func loadMistakes() {
        mistakes = sqliteService.fetchMistakes()
        reviewItems = Array(mistakes.shuffled().prefix(10))
    }

    func select(_ option: String) {
        guard !isAnswered, let item = current else { return }
        selectedOption = option
        isAnswered = true
        if option == item.correctAnswer {
            correctCount += 1
            sqliteService.deleteMistake(id: item.id)
            HapticService.shared.notify(.success)
        } else {
            HapticService.shared.notify(.error)
        }
    }

    func next() {
        HapticService.shared.impact(.light)
        if currentIndex + 1 >= reviewItems.count {
            isFinished = true
        } else {
            currentIndex += 1
            selectedOption = nil
            isAnswered = false
        }
    }

    func buildOptions(for item: MistakeItem) -> [String] {
        // correct + wrong answer + 2 random from other mistakes
        var opts = Set([item.correctAnswer, item.userAnswer])
        for m in mistakes.shuffled() where opts.count < 4 {
            opts.insert(m.correctAnswer)
        }
        return Array(opts).shuffled()
    }
}
