import Foundation
import Combine

final class ListeningViewModel: ObservableObject {
    @Published var exercises: [ListeningExercise] = []

    private let repository: ContentRepository

    init(repository: ContentRepository) {
        self.repository = repository
        exercises = repository.fetchListeningExercises()
    }
}
