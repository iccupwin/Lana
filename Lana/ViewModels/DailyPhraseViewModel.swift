import Foundation
import Combine

final class DailyPhraseViewModel: ObservableObject {
    @Published var phrase: DailyPhrase?

    private let repository: ContentRepository

    init(repository: ContentRepository) {
        self.repository = repository
        loadTodayPhrase()
    }

    private func loadTodayPhrase() {
        let all = repository.fetchDailyPhrases().sorted { $0.dayIndex < $1.dayIndex }
        guard !all.isEmpty else { return }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = (dayOfYear - 1) % all.count
        phrase = all[index]
    }
}
