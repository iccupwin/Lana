import Foundation
import Combine

final class QuizViewModel: ObservableObject {
    @Published var currentQuiz: Quiz?
    @Published var currentQuestionIndex = 0
    @Published var selectedIndex: Int?
    @Published var showExplanation = false
    @Published var correctCount = 0
    @Published var isCompleted = false
    @Published var questionResults: [Bool] = []

    private let repository: ContentRepository
    private let sqliteService: SQLiteService

    init(repository: ContentRepository, sqliteService: SQLiteService, quizId: String? = nil) {
        self.repository = repository
        self.sqliteService = sqliteService
        let all = repository.fetchQuizzes()
        if let id = quizId {
            currentQuiz = all.first(where: { $0.id == id }) ?? all.first
        } else {
            currentQuiz = all.first
        }
    }

    var currentQuestion: QuizQuestion? {
        guard let quiz = currentQuiz, currentQuestionIndex < quiz.questions.count else { return nil }
        return quiz.questions[currentQuestionIndex]
    }

    var progress: Double {
        guard let quiz = currentQuiz, !quiz.questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(quiz.questions.count)
    }

    func selectAnswer(_ index: Int) {
        guard selectedIndex == nil, let question = currentQuestion else { return }
        selectedIndex = index
        showExplanation = true
        let correct = index == question.correctIndex
        questionResults.append(correct)
        if correct {
            correctCount += 1
        } else {
            HeartsService.shared.useHeart()
            sqliteService.saveMistake(
                questionText: question.text,
                correctAnswer: question.options[question.correctIndex],
                userAnswer: question.options[index],
                source: "Quiz"
            )
        }
    }

    func nextQuestion() {
        guard let quiz = currentQuiz else { return }
        if currentQuestionIndex + 1 < quiz.questions.count {
            currentQuestionIndex += 1
            selectedIndex = nil
            showExplanation = false
        } else {
            isCompleted = true
            let result = QuizResult(quizId: quiz.id, correctCount: correctCount, totalCount: quiz.questions.count, date: Date())
            sqliteService.saveQuizResult(result)
        }
    }

    func restart() {
        currentQuestionIndex = 0
        selectedIndex = nil
        showExplanation = false
        correctCount = 0
        isCompleted = false
        questionResults = []
    }
}
