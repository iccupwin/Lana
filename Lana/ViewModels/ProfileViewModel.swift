import Foundation
import Combine
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @AppStorage("userName") var name: String = ""
    @Published var bio: String = ""
    @Published var stats = ProgressStats(quizzesTaken: 0, correctAnswers: 0, learnedWords: 0, currentStreak: 0)

    private let sqliteService: SQLiteService

    init(sqliteService: SQLiteService = .shared) {
        self.sqliteService = sqliteService
        refresh()
    }

    func refresh() {
        stats = sqliteService.fetchProgress()
    }
}
