import SwiftUI

// Always light theme. Dark mode is opt-in via SettingsView (preferredColorScheme).
enum LightDesignSystem {

    // MARK: - Background & Text
    static let background     = Color.white
    static let ink            = Color(red: 0.11, green: 0.11, blue: 0.13)
    static let muted          = Color(red: 0.55, green: 0.55, blue: 0.58)

    // MARK: - Card / Surface
    static let cardBackground = Color.white
    static let cardBorder     = Color(red: 0.84, green: 0.84, blue: 0.86)   // #D6D6DC

    // MARK: - Primary Accent (Blue)
    static let accent         = Color(red: 0.29, green: 0.56, blue: 0.97)   // #4A8FF7

    // MARK: - Answer States
    static let correctBg      = Color(red: 0.89, green: 0.97, blue: 0.92)   // #E3F7EB
    static let correctBorder  = Color(red: 0.20, green: 0.78, blue: 0.35)   // #34C759
    static let wrongBg        = Color(red: 1.00, green: 0.93, blue: 0.93)   // #FFEDED
    static let wrongBorder    = Color(red: 1.00, green: 0.23, blue: 0.19)   // #FF3B30

    // MARK: - Pill / Segment
    static let pill           = Color(red: 0.29, green: 0.56, blue: 0.97).opacity(0.15)
    static let pillInactive   = Color(red: 0.91, green: 0.91, blue: 0.93)   // #E8E8ED

    // MARK: - Shadow
    static let shadow         = Color.black.opacity(0.07)

    // MARK: - Card Accent Colors
    static let cardYellow     = Color(red: 0.98, green: 0.79, blue: 0.32)
    static let cardSky        = Color(red: 0.29, green: 0.56, blue: 0.97)
    static let cardGreen      = Color(red: 0.20, green: 0.78, blue: 0.43)
    static let cardLilac      = Color(red: 0.62, green: 0.56, blue: 0.97)
    static let cardPink       = Color(red: 0.97, green: 0.55, blue: 0.74)
    static let cardMint       = Color(red: 0.44, green: 0.82, blue: 0.68)
    static let cardPeach      = Color(red: 0.97, green: 0.62, blue: 0.44)
    static let cardLavender   = Color(red: 0.68, green: 0.59, blue: 0.97)

    // MARK: - Card Style
    static let cardRadius: CGFloat = 16
}

// MARK: - Typography

extension Font {
    static func serifTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }
    static func serifItalic(_ size: CGFloat) -> Font {
        .system(size: size, design: .serif).italic()
    }
    static func roundedTitle(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
    static func roundedBody(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
}
