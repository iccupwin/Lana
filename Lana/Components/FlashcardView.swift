import SwiftUI

struct FlashcardView: View {
    let word: String
    let translation: String
    @State private var isFlipped = false

    var body: some View {
        ColoredCard(color: DesignSystem.cardYellow) {
            VStack(spacing: 12) {
                Text(isFlipped ? translation : word)
                    .font(.title(20))
                    .foregroundStyle(DesignSystem.darkInk)
                Text(isFlipped ? "Translation" : "Word")
                    .font(.bodyText(12))
                    .foregroundStyle(DesignSystem.darkInk.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .frame(height: 200)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isFlipped.toggle()
            }
        }
    }
}
