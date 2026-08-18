import Foundation
import Combine

final class SavedWordsViewModel: ObservableObject {
    @Published var savedWords: [SavedWord] = []
    @Published var flashcardIndex = 0
    @Published var dueWordIds: Set<String> = []

    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService) {
        self.sqliteService = sqliteService
        load()
    }

    func load() {
        savedWords = sqliteService.fetchSavedWords()
        dueWordIds = sqliteService.fetchDueWordIds()
        // Start from the first word due for review, if any
        if let firstDue = savedWords.firstIndex(where: { dueWordIds.contains($0.id) }) {
            flashcardIndex = firstDue
        } else {
            flashcardIndex = 0
        }
    }

    func removeWord(id: String) {
        sqliteService.removeWord(id: id)
        load()
    }

    var currentFlashcard: SavedWord? {
        guard flashcardIndex < savedWords.count else { return nil }
        return savedWords[flashcardIndex]
    }

    var dueCount: Int { dueWordIds.count }

    func isDue(_ word: SavedWord) -> Bool {
        dueWordIds.contains(word.id)
    }

    func daysUntilReview(_ word: SavedWord) -> Int {
        sqliteService.daysUntilReview(wordId: word.id)
    }

    /// Called when user rates the current flashcard.
    /// quality: 1 = Again, 3 = Hard, 5 = Easy
    func reviewCurrentWord(quality: Int) {
        guard let card = currentFlashcard else { return }
        sqliteService.recordSRSReview(wordId: card.id, quality: quality)
        sqliteService.addXP(5)
        dueWordIds = sqliteService.fetchDueWordIds()
        advanceToNextDueOrNext()
    }

    func nextFlashcard() {
        guard flashcardIndex + 1 < savedWords.count else {
            flashcardIndex = 0
            return
        }
        flashcardIndex += 1
    }

    private func advanceToNextDueOrNext() {
        let total = savedWords.count
        guard total > 0 else { return }
        // Try to find next due word after current index
        for offset in 1...total {
            let next = (flashcardIndex + offset) % total
            if dueWordIds.contains(savedWords[next].id) {
                flashcardIndex = next
                return
            }
        }
        // No more due words — just advance
        nextFlashcard()
    }
}
