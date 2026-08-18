import Foundation
import SwiftUI

// MARK: - Mistake Item

struct MistakeItem: Identifiable {
    let id: Int
    let questionText: String
    let correctAnswer: String
    let userAnswer: String
    let source: String
    let createdAt: Date
}

// MARK: - Word Mastery Level

enum WordMasteryLevel: Int {
    case new       = 0  // 0 repetitions
    case learning  = 1  // 1–2
    case familiar  = 2  // 3–4
    case mastered  = 3  // 5+

    static func level(for repetitions: Int) -> WordMasteryLevel {
        switch repetitions {
        case 0:    return .new
        case 1, 2: return .learning
        case 3, 4: return .familiar
        default:   return .mastered
        }
    }

    var label: String {
        switch self {
        case .new:      return "New"
        case .learning: return "Learning"
        case .familiar: return "Familiar"
        case .mastered: return "Mastered"
        }
    }

    var color: Color {
        switch self {
        case .new:      return Color.white.opacity(0.2)
        case .learning: return Color(red: 0.98, green: 0.79, blue: 0.20)
        case .familiar: return Color(red: 0.22, green: 0.44, blue: 0.98)
        case .mastered: return Color(red: 0.20, green: 0.78, blue: 0.43)
        }
    }

    var icon: String {
        switch self {
        case .new:      return "circle"
        case .learning: return "circle.lefthalf.filled"
        case .familiar: return "circle.righthalf.filled"
        case .mastered: return "checkmark.circle.fill"
        }
    }
}
