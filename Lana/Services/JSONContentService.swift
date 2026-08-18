import Foundation

/// Loads teacher-managed content from JSON bundled with the app.
final class JSONContentService: ContentRepository {
    private let decoder = JSONDecoder()
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchQuizzes() -> [Quiz] {
        loadJSON(named: "quizzes") ?? []
    }

    func fetchWords() -> [Word] {
        loadJSON(named: "words") ?? []
    }

    func fetchMovieScenes() -> [MovieScene] {
        loadJSON(named: "movies") ?? []
    }

    func fetchGrammarTopics() -> [GrammarTopic] {
        loadJSON(named: "grammar") ?? []
    }

    func fetchListeningExercises() -> [ListeningExercise] {
        loadJSON(named: "listening") ?? []
    }

    func fetchDailyPhrases() -> [DailyPhrase] {
        loadJSON(named: "phrases") ?? []
    }

    func fetchStories() -> [Story] {
        loadJSON(named: "stories") ?? []
    }

    func fetchIdioms() -> [Idiom] {
        loadJSON(named: "idioms") ?? []
    }

    private func loadJSON<T: Decodable>(named name: String) -> T? {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}
