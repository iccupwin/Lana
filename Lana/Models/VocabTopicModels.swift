import Foundation

struct VocabTopic: Identifiable {
    let id: String
    let title: String
    let icon: String       // SF Symbol name (replaces emoji for iOS 26 compatibility)
    let colorHex: String
    let words: [TopicWord]
}

struct TopicWord: Identifiable {
    let id: String
    let word: String
    let translation: String
    let example: String
}
