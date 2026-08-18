import Foundation
import Combine
import UIKit

// MARK: - MatchCard

struct MatchCard: Identifiable, Equatable {
    let id = UUID()
    let pairId: String   // shared key between English + Russian card of a pair
    let text: String
    let isEnglish: Bool

    enum CardState { case idle, selected, matched, wrong }
    var state: CardState = .idle
}

// MARK: - ViewModel

final class MatchMadnessViewModel: ObservableObject {
    @Published var cards: [MatchCard] = []
    @Published var score: Int = 0
    @Published var combo: Int = 0
    @Published var timeLeft: Double = 60
    @Published var isFinished: Bool = false
    @Published var matchedPairsTotal: Int = 0  // across all rounds

    private var selectedId: UUID? = nil
    private var timer: Timer?

    // Word pool – 30 pairs; rounds pick 6 at a time
    private let pool: [(String, String)] = [
        ("symptom",       "симптом"),
        ("prescription",  "рецепт"),
        ("appointment",   "приём"),
        ("treatment",     "лечение"),
        ("episode",       "серия"),
        ("sequel",        "продолжение"),
        ("ingredient",    "ингредиент"),
        ("cuisine",       "кухня"),
        ("deadline",      "дедлайн"),
        ("promotion",     "повышение"),
        ("itinerary",     "маршрут"),
        ("landmark",      "ориентир"),
        ("occupation",    "профессия"),
        ("fluent",        "свободный"),
        ("passion",       "страсть"),
        ("aspiration",    "стремление"),
        ("milestone",     "веха"),
        ("feedback",      "обратная связь"),
        ("colleague",     "коллега"),
        ("departure",     "отправление"),
        ("curious",       "любознательный"),
        ("confident",     "уверенный"),
        ("improve",       "улучшать"),
        ("achieve",       "достигать"),
        ("consistent",    "последовательный"),
        ("generous",      "щедрый"),
        ("genuine",       "искренний"),
        ("persuade",      "убеждать"),
        ("sacrifice",     "жертвовать"),
        ("obstacle",      "препятствие"),
    ]

    init() {
        loadRound()
        startTimer()
    }

    // MARK: Round

    private func loadRound() {
        let six = pool.shuffled().prefix(6)
        var newCards: [MatchCard] = []
        for (eng, rus) in six {
            newCards.append(MatchCard(pairId: eng, text: eng, isEnglish: true))
            newCards.append(MatchCard(pairId: eng, text: rus, isEnglish: false))
        }
        cards = newCards.shuffled()
    }

    // MARK: Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self, !self.isFinished else { return }
                self.timeLeft = max(0, self.timeLeft - 0.05)
                if self.timeLeft <= 0 { self.finish() }
            }
        }
    }

    // MARK: Tap

    func tap(_ card: MatchCard) {
        guard (card.state == .idle || card.state == .selected), !isFinished else { return }

        // Deselect if same card
        guard let firstId = selectedId else {
            selectedId = card.id
            setState(card.id, .selected)
            HapticService.shared.impact(.light)
            return
        }
        if firstId == card.id {
            selectedId = nil
            setState(firstId, .idle)
            return
        }

        guard let firstCard = cards.first(where: { $0.id == firstId }) else { return }

        if firstCard.pairId == card.pairId {
            // ✅ Correct match
            combo += 1
            score += 100 + min(combo - 1, 5) * 25
            timeLeft = min(60, timeLeft + 3)
            HapticService.shared.notify(.success)
            setState(firstId, .matched)
            setState(card.id, .matched)
            matchedPairsTotal += 1
            selectedId = nil
            // Check round complete
            let remaining = cards.filter { $0.state != .matched }.count
            if remaining == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                    self?.loadRound()
                }
            }
        } else {
            // ❌ Wrong pair
            combo = 0
            HeartsService.shared.useHeart()
            HapticService.shared.notify(.error)
            setState(firstId, .wrong)
            setState(card.id, .wrong)
            let a = firstId, b = card.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { [weak self] in
                self?.setState(a, .idle)
                self?.setState(b, .idle)
            }
            selectedId = nil
        }
    }

    // MARK: Finish

    func finish() {
        timer?.invalidate()
        timer = nil
        isFinished = true
        let xp = max(5, score / 10)
        SQLiteService.shared.addXP(xp)
        HapticService.shared.notify(.success)
    }

    var xpEarned: Int { max(5, score / 10) }

    // MARK: Helpers

    private func setState(_ id: UUID, _ state: MatchCard.CardState) {
        if let i = cards.firstIndex(where: { $0.id == id }) {
            cards[i].state = state
        }
    }
}
