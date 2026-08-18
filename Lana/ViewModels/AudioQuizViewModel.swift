import Foundation
import AVFoundation
import Combine
import UIKit

struct AudioQuizQuestion: Identifiable {
    let id = UUID()
    let word: String
    let correctTranslation: String
    let options: [String]    // 4 translations, correct included
}

final class AudioQuizViewModel: ObservableObject {
    @Published var questions: [AudioQuizQuestion] = []
    @Published var currentIndex: Int = 0
    @Published var selectedOption: String? = nil
    @Published var isAnswered: Bool = false
    @Published var score: Int = 0
    @Published var isFinished: Bool = false
    @Published var isSpeaking: Bool = false

    private let synthesizer = AVSpeechSynthesizer()

    init() { buildQuestions() }

    var current: AudioQuizQuestion? { questions.isEmpty ? nil : questions[currentIndex] }
    var progress: Double { questions.isEmpty ? 0 : Double(currentIndex) / Double(questions.count) }

    func speakCurrent() {
        guard let q = current else { return }
        speak(q.word)
    }

    private func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.42
        utterance.pitchMultiplier = 1.0
        isSpeaking = true
        synthesizer.speak(utterance)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.isSpeaking = false
        }
    }

    func select(_ option: String) {
        guard !isAnswered, let q = current else { return }
        selectedOption = option
        isAnswered = true
        if option == q.correctTranslation {
            score += 1
            HapticService.shared.notify(.success)
        } else {
            HapticService.shared.notify(.error)
        }
    }

    func next() {
        HapticService.shared.impact(.light)
        if currentIndex + 1 >= questions.count {
            isFinished = true
        } else {
            currentIndex += 1
            selectedOption = nil
            isAnswered = false
            // auto-play next word
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.speakCurrent()
            }
        }
    }

    private func buildQuestions() {
        let vocab: [(String, String)] = [
            ("ambiguous",    "неоднозначный"),
            ("consequence",  "последствие"),
            ("inevitable",   "неизбежный"),
            ("sufficient",   "достаточный"),
            ("acknowledge",  "признавать"),
            ("emphasize",    "подчёркивать"),
            ("fundamental",  "фундаментальный"),
            ("perspective",  "точка зрения"),
            ("circumstance", "обстоятельство"),
            ("contribute",   "вносить вклад"),
            ("diminish",     "уменьшать"),
            ("elaborate",    "подробный"),
        ]
        let shuffled = vocab.shuffled()
        let all = shuffled.prefix(10)
        let allTranslations = vocab.map { $0.1 }

        questions = all.map { (word, translation) in
            var opts = Set([translation])
            for t in allTranslations.shuffled() where opts.count < 4 { opts.insert(t) }
            return AudioQuizQuestion(
                word: word,
                correctTranslation: translation,
                options: Array(opts).shuffled()
            )
        }
    }
}
