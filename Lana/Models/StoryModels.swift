import Foundation

struct Story: Identifiable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let cefrLevel: String       // "A1" | "A2" | "B1" | "B2"
    let colorHex: String
    let iconSystemName: String
    let paragraphs: [StoryParagraph]
    let questions: [StoryQuestion]
}

struct StoryParagraph: Identifiable, Codable {
    let id: String
    let text: String
    let highlightedWords: [HighlightedWord]
}

struct HighlightedWord: Codable {
    let word: String
    let definition: String
    let translation: String
}

struct StoryQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let options: [String]
    let correctIndex: Int
}
