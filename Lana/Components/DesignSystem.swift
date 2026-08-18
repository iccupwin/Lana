import SwiftUI

enum DesignSystem {
    static let background = LotusApp.pearl
    static let cardYellow = Color(red: 0.98, green: 0.79, blue: 0.32)
    static let cardGreen = Color(red: 0.31, green: 0.75, blue: 0.63)
    static let cardPurple = Color(red: 0.62, green: 0.45, blue: 0.95)
    static let cardTeal = Color(red: 0.29, green: 0.78, blue: 0.62)
    static let softWhite = LotusApp.ink
    static let mutedWhite = LotusApp.muted
    static let darkInk = LotusApp.ink

    static let cornerRadius: CGFloat = 22
    static let cardShadow = LotusApp.ink.opacity(0.08)
}

extension Font {
    static func display(_ size: CGFloat) -> Font {
        Font.system(size: size, weight: .bold, design: .rounded)
    }

    static func title(_ size: CGFloat) -> Font {
        Font.system(size: size, weight: .semibold, design: .rounded)
    }

    static func bodyText(_ size: CGFloat) -> Font {
        Font.system(size: size, weight: .regular, design: .rounded)
    }
}
