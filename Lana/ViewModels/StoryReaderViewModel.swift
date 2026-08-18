import Foundation
import Combine

final class StoryReaderViewModel: ObservableObject {
    @Published var currentParagraphIndex: Int = 0
    @Published var selectedWord: HighlightedWord?
    @Published var showQuiz: Bool = false
    @Published var quizAnswers: [Int?]
    @Published var quizSubmitted: Bool = false
    @Published var isCompleted: Bool = false

    let story: Story
    private let sqliteService: SQLiteService

    init(story: Story, sqliteService: SQLiteService) {
        self.story = story
        self.sqliteService = sqliteService
        self.quizAnswers = Array(repeating: nil, count: story.questions.count)
        let saved = sqliteService.fetchStoryParagraphIndex(storyId: story.id)
        self.currentParagraphIndex = min(saved, story.paragraphs.count - 1)
        self.isCompleted = sqliteService.isStoryComplete(story.id)
    }

    var canGoNext: Bool { currentParagraphIndex < story.paragraphs.count - 1 }
    var isLastParagraph: Bool { currentParagraphIndex == story.paragraphs.count - 1 }
    var currentParagraph: StoryParagraph { story.paragraphs[currentParagraphIndex] }

    var correctCount: Int {
        guard quizSubmitted else { return 0 }
        return story.questions.enumerated().filter { i, q in quizAnswers[i] == q.correctIndex }.count
    }

    func nextParagraph() {
        guard canGoNext else { return }
        currentParagraphIndex += 1
        sqliteService.saveStoryProgress(storyId: story.id, paragraphIndex: currentParagraphIndex)
        if isLastParagraph { showQuiz = true }
    }

    func selectAnswer(_ index: Int, for questionIndex: Int) {
        guard !quizSubmitted else { return }
        quizAnswers[questionIndex] = index
    }

    func submitQuiz(appState: AppState) {
        quizSubmitted = true
        if !isCompleted {
            isCompleted = true
            sqliteService.markStoryComplete(story.id)
            appState.awardXPOnce(key: "story_\(story.id)", amount: 40)
        }
    }
}
