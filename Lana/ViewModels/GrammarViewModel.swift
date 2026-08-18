import Foundation
import Combine

final class GrammarViewModel: ObservableObject {
    @Published var topics: [GrammarTopic] = []

    private let repository: ContentRepository

    init(repository: ContentRepository) {
        self.repository = repository
        topics = repository.fetchGrammarTopics()
    }
}
