import Foundation
import Combine

final class MoviesViewModel: ObservableObject {
    @Published var scenes: [MovieScene] = []

    private let repository: ContentRepository

    init(repository: ContentRepository) {
        self.repository = repository
        scenes = repository.fetchMovieScenes()
    }
}
