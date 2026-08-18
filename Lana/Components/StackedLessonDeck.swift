import SwiftUI

struct StackedLessonDeck: View {
    let cards: [LessonCard]
    @State private var appeared = false

    // The visible peek height for background cards
    private let peekHeight: CGFloat = 14
    // Height of the front card
    private let frontCardHeight: CGFloat = 80

    private var visibleCards: [LessonCard] {
        Array(cards.suffix(7))
    }

    private var deckHeight: CGFloat {
        guard !visibleCards.isEmpty else { return 0 }
        let backgroundPeek = CGFloat(visibleCards.count - 1) * peekHeight
        return frontCardHeight + backgroundPeek
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background cards (fanned upward behind the front card)
            // Reversed enumeration so furthest-back card is drawn first (lowest z)
            ForEach(Array(visibleCards.dropLast().enumerated()), id: \.element.id) { index, card in
                let totalBehind = visibleCards.count - 1
                let distanceFromFront = totalBehind - index // how far behind the front card
                let offsetUp = CGFloat(distanceFromFront) * peekHeight
                let scaleX = 1 - CGFloat(distanceFromFront) * 0.015

                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(hex: card.colorHex))
                    .frame(height: frontCardHeight)
                    .scaleEffect(x: scaleX, y: 1, anchor: .bottom)
                    .offset(y: -offsetUp + (appeared ? 0 : 14))
                    .opacity(appeared ? 1.0 : 0.75)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.78)
                            .delay(Double(distanceFromFront) * 0.04),
                        value: appeared
                    )
            }

            // Front card (on top in z-order, at the bottom visually)
            if let frontCard = visibleCards.last {
                LessonCardView(card: frontCard, style: .stacked)
                    .offset(y: appeared ? 0 : 8)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.85),
                        value: appeared
                    )
            }
        }
        .frame(maxWidth: .infinity, minHeight: deckHeight, alignment: .bottom)
        .padding(.bottom, 8)
        .allowsHitTesting(false)
        .onAppear {
            guard !appeared else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                appeared = true
            }
        }
    }
}
