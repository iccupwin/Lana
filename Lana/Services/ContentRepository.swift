import Foundation

protocol ContentRepository {
    func fetchQuizzes() -> [Quiz]
    func fetchWords() -> [Word]
    func fetchMovieScenes() -> [MovieScene]
    func fetchGrammarTopics() -> [GrammarTopic]
    func fetchListeningExercises() -> [ListeningExercise]
    func fetchDailyPhrases() -> [DailyPhrase]
    func fetchStories() -> [Story]
    func fetchIdioms() -> [Idiom]
}
