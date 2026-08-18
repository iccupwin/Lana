import SwiftUI

// MARK: - Brand Color Tokens
// Single source of truth for all home-screen brand colors.
// No hex literals should appear inline in view code.

extension Color {
    /// Primary interactive blue — #378ADD
    static let appBlue      = Color(red: 0.216, green: 0.541, blue: 0.867)
    /// Muted green for XP / progress indicators — #639922
    static let appGreen     = Color(red: 0.388, green: 0.600, blue: 0.133)
    /// Danger / lives (hearts) — #E24B4A
    static let appDanger    = Color(red: 0.886, green: 0.294, blue: 0.290)
    /// Card background in the Lotus light system.
    static let appCard      = Color.white.opacity(0.86)
    /// Page background in the Lotus light system.
    static let appBg        = LotusApp.pearl
    /// Avatar circle fill — #1A3A5C
    static let appAvatarBg  = Color(red: 0.102, green: 0.227, blue: 0.361)
    /// Avatar initials text — #85B7EB
    static let appAvatarText = Color(red: 0.522, green: 0.718, blue: 0.922)
    /// Amber border for 1st-place league chip — #EF9F27
    static let appAmber     = Color(red: 0.937, green: 0.624, blue: 0.153)
    /// Stat pill background — #1A1A1A
    static let appStatBg    = LotusApp.ink.opacity(0.045)
    /// Progress track background — #222222
    static let appTrackBg   = LotusApp.ink.opacity(0.065)
}
