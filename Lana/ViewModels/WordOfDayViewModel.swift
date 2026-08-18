import Foundation
import Combine

final class WordOfDayViewModel: ObservableObject {
    @Published var words: [Word] = []
    @Published var currentIndex = 0

    private let repository: ContentRepository
    private let sqliteService: SQLiteService

    init(repository: ContentRepository, sqliteService: SQLiteService) {
        self.repository = repository
        self.sqliteService = sqliteService
        words = repository.fetchWords()
        if let index = words.firstIndex(where: { $0.dayIndex == Calendar.current.component(.day, from: Date()) }) {
            currentIndex = index
        }
    }

    var currentWord: Word? {
        guard currentIndex < words.count else { return nil }
        return words[currentIndex]
    }

    func saveCurrentWord() {
        guard let word = currentWord else { return }
        sqliteService.saveWord(word)
    }

    func nextWord() {
        guard currentIndex + 1 < words.count else { return }
        currentIndex += 1
    }

    func previousWord() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }
}
