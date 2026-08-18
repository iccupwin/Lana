import Foundation

struct LessonCard: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let description: String
    let rating: Int
    let colorHex: String
    let iconSystemName: String
}

struct ChatMessage: Identifiable, Hashable {
    let id: String
    let text: String
    let isUser: Bool
}
