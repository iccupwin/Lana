import Foundation
import Combine

final class StoriesViewModel: ObservableObject {
    @Published var stories: [Story] = []
    @Published var completedStoryIds: Set<String> = []

    private let repository: ContentRepository
    private let sqliteService: SQLiteService

    init(repository: ContentRepository, sqliteService: SQLiteService) {
        self.repository = repository
        self.sqliteService = sqliteService
        load()
    }

    func load() {
        stories = repository.fetchStories()
        completedStoryIds = sqliteService.fetchCompletedStoryIds()
    }

    func isCompleted(_ story: Story) -> Bool {
        completedStoryIds.contains(story.id)
    }
}
