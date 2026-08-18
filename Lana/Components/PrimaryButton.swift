import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title(16))
                .foregroundStyle(DesignSystem.darkInk)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(DesignSystem.cardYellow)
                )
        }
        .buttonStyle(.plain)
    }
}
