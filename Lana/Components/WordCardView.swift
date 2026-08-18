import SwiftUI

struct WordCardView: View {
    let word: Word

    var body: some View {
        ColoredCard(color: DesignSystem.cardTeal) {
            HStack {
                Text(word.word)
                    .font(.title(22))
                    .foregroundStyle(DesignSystem.darkInk)
                Spacer()
                Text(word.phonetic)
                    .font(.bodyText(12))
                    .foregroundStyle(DesignSystem.darkInk.opacity(0.7))
            }

            Text(word.translation)
                .font(.title(16))
                .foregroundStyle(DesignSystem.darkInk)

            Text(word.example)
                .font(.bodyText(12))
                .foregroundStyle(DesignSystem.darkInk.opacity(0.7))
                .padding(.top, 4)
        }
    }
}
