import Foundation
import Combine

// MARK: - Search Result

enum SearchResultKind {
    case word, grammar, story, lesson, idiom
}

struct SearchResult: Identifiable {
    let id: String
    let kind: SearchResultKind
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: String   // hex-ish label for the dot
}

// MARK: - Search Topic (Browse by Category)

struct SearchTopic: Identifiable {
    let id: String
    let title: String
    let icon: String
    let colorHex: String
    let filterTag: String   // maps to Word.register or category tag
}

// MARK: - ViewModel

final class SearchViewModel: ObservableObject {

    @Published var query: String = ""
    @Published var results: [SearchResult] = []
    @Published var isSearching: Bool = false

    let hotTopics: [String] = [
        "Present Perfect", "Phrasal Verbs", "Business English",
        "Travel Vocabulary", "Slang & Idioms", "Conditionals"
    ]

    let categories: [SearchTopic] = [
        SearchTopic(id: "business",  title: "Business",       icon: "briefcase.fill",      colorHex: "#5B8EF7", filterTag: "formal"),
        SearchTopic(id: "travel",    title: "Travel",          icon: "airplane",             colorHex: "#F7A25B", filterTag: "travel"),
        SearchTopic(id: "daily",     title: "Daily Life",      icon: "house.fill",           colorHex: "#5BF7A2", filterTag: "neutral"),
        SearchTopic(id: "slang",     title: "Slang",           icon: "bolt.fill",            colorHex: "#F75BB5", filterTag: "slang"),
        SearchTopic(id: "academic",  title: "Academic",        icon: "books.vertical.fill",  colorHex: "#A25BF7", filterTag: "academic"),
        SearchTopic(id: "idioms",    title: "Idioms",          icon: "quote.bubble.fill",    colorHex: "#F7D55B", filterTag: "idiom"),
        SearchTopic(id: "grammar",   title: "Grammar",         icon: "textformat.abc",       colorHex: "#5BE8F7", filterTag: "grammar"),
        SearchTopic(id: "culture",   title: "Culture",         icon: "globe",                colorHex: "#F77A5B", filterTag: "culture"),
    ]

    private let contentRepository: ContentRepository
    private var cancellables = Set<AnyCancellable>()

    init(contentRepository: ContentRepository = JSONContentService()) {
        self.contentRepository = contentRepository

        $query
            .debounce(for: .milliseconds(250), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] q in
                self?.performSearch(q)
            }
            .store(in: &cancellables)
    }

    // MARK: - Search

    private func performSearch(_ q: String) {
        let trimmed = q.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 2 else {
            results = []
            isSearching = false
            return
        }

        isSearching = true
        let lower = trimmed.lowercased()
        var found: [SearchResult] = []

        // Words
        let words = contentRepository.fetchWords()
        for w in words where w.word.lowercased().contains(lower) || w.translation.lowercased().contains(lower) {
            found.append(SearchResult(
                id: "word_\(w.id)",
                kind: .word,
                title: w.word,
                subtitle: w.translation,
                icon: "textformat.size",
                accentColor: "blue"
            ))
            if found.count > 40 { break }
        }

        // Grammar
        let grammar = contentRepository.fetchGrammarTopics()
        for g in grammar where g.title.lowercased().contains(lower) || g.explanation.lowercased().contains(lower) {
            found.append(SearchResult(
                id: "grammar_\(g.id)",
                kind: .grammar,
                title: g.title,
                subtitle: "Grammar topic",
                icon: "textformat.abc",
                accentColor: "green"
            ))
        }

        // Stories
        let stories = contentRepository.fetchStories()
        for s in stories where s.title.lowercased().contains(lower) {
            found.append(SearchResult(
                id: "story_\(s.id)",
                kind: .story,
                title: s.title,
                subtitle: "Story · \(s.cefrLevel)",
                icon: "books.vertical.fill",
                accentColor: "purple"
            ))
        }

        // Idioms
        let idioms = contentRepository.fetchIdioms()
        for i in idioms where i.phrase.lowercased().contains(lower) || i.meaning.lowercased().contains(lower) {
            found.append(SearchResult(
                id: "idiom_\(i.id)",
                kind: .idiom,
                title: i.phrase,
                subtitle: i.meaning,
                icon: "quote.bubble.fill",
                accentColor: "orange"
            ))
        }

        // Static lessons
        let lessons: [(id: String, title: String, subtitle: String)] = [
            ("health",   "Health Care",          "Talk about health & fitness"),
            ("tv",       "Favorite TV Series",   "Discuss your favorite shows"),
            ("food",     "Food & Cooking",        "Share recipes and cuisine"),
            ("work",     "Work & Career",         "Professional vocabulary"),
            ("travel",   "Places to Visit",       "Travel experiences"),
            ("personal", "Personal Information",  "Introduce yourself"),
            ("hobbies",  "Your Hobbies",          "Interests & free time"),
            ("future",   "Future Plans",          "Goals and dreams"),
        ]
        for l in lessons where l.title.lowercased().contains(lower) || l.subtitle.lowercased().contains(lower) {
            found.append(SearchResult(
                id: "lesson_\(l.id)",
                kind: .lesson,
                title: l.title,
                subtitle: l.subtitle,
                icon: "book.fill",
                accentColor: "lime"
            ))
        }

        results = found
        isSearching = false
    }

    func topicResults(for topic: SearchTopic) -> [SearchResult] {
        var found: [SearchResult] = []
        let tag = topic.filterTag

        let words = contentRepository.fetchWords()
        for w in words where (w.register ?? "").lowercased() == tag || tag == "neutral" {
            found.append(SearchResult(
                id: "word_\(w.id)",
                kind: .word,
                title: w.word,
                subtitle: w.translation,
                icon: "textformat.size",
                accentColor: "blue"
            ))
            if found.count > 30 { break }
        }

        if tag == "idiom" {
            let idioms = contentRepository.fetchIdioms()
            for i in idioms {
                found.append(SearchResult(
                    id: "idiom_\(i.id)",
                    kind: .idiom,
                    title: i.phrase,
                    subtitle: i.meaning,
                    icon: "quote.bubble.fill",
                    accentColor: "orange"
                ))
            }
        }

        if tag == "grammar" {
            let grammar = contentRepository.fetchGrammarTopics()
            for g in grammar {
                found.append(SearchResult(
                    id: "grammar_\(g.id)",
                    kind: .grammar,
                    title: g.title,
                    subtitle: "Grammar topic",
                    icon: "textformat.abc",
                    accentColor: "green"
                ))
            }
        }

        return found
    }
}
