import SwiftUI

struct AppTheme {
    let background: Color
    let card: Color
    let cardAlt: Color
    let accent: Color
    let accentSecondary: Color
    let muted: Color
    let border: Color
    let success: Color
    let error: Color
    let warning: Color
    
    let cornerRadius: CGFloat
    
    static let dark = AppTheme(
        background: LotusApp.pearl,
        card: Color.white.opacity(0.86),
        cardAlt: LotusApp.ink.opacity(0.055),
        accent: LotusApp.cobalt,
        accentSecondary: LotusApp.violet,
        muted: LotusApp.muted,
        border: LotusApp.ink.opacity(0.075),
        success: LotusApp.mint,
        error: LotusApp.danger,
        warning: LotusApp.amber,
        cornerRadius: 20
    )
    
    static let light = AppTheme(
        background: Color.white,
        card: Color(red: 0.97, green: 0.97, blue: 0.98),
        cardAlt: Color(red: 0.93, green: 0.93, blue: 0.95),
        accent: Color(red: 0.29, green: 0.56, blue: 0.97),
        accentSecondary: Color(red: 0.62, green: 0.56, blue: 0.97),
        muted: Color(red: 0.55, green: 0.55, blue: 0.58),
        border: Color(red: 0.84, green: 0.84, blue: 0.86),
        success: Color(red: 0.20, green: 0.78, blue: 0.43),
        error: Color(red: 1.00, green: 0.23, blue: 0.19),
        warning: Color(red: 0.98, green: 0.60, blue: 0.18),
        cornerRadius: 16
    )
}

struct AppGradients {
    static let lime = LinearGradient(
        colors: [Color(red: 0.773, green: 0.945, blue: 0.196),
                 Color(red: 0.62, green: 0.82, blue: 0.10)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let blue = LinearGradient(
        colors: [Color(red: 0.22, green: 0.44, blue: 0.98),
                 Color(red: 0.14, green: 0.28, blue: 0.75)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let purple = LinearGradient(
        colors: [Color(red: 0.62, green: 0.38, blue: 0.98),
                 Color(red: 0.44, green: 0.22, blue: 0.78)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let orange = LinearGradient(
        colors: [Color(red: 0.98, green: 0.60, blue: 0.18),
                 Color(red: 0.88, green: 0.42, blue: 0.08)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    static let green = LinearGradient(
        colors: [Color(red: 0.20, green: 0.78, blue: 0.43),
                 Color(red: 0.15, green: 0.60, blue: 0.35)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}

struct CardStyle: ViewModifier {
    let theme: AppTheme
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.card)
            )
    }
}

struct AccentCardStyle: ViewModifier {
    let gradient: LinearGradient
    
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(gradient)
            )
    }
}

extension View {
    func cardStyle(_ theme: AppTheme) -> some View {
        modifier(CardStyle(theme: theme))
    }
    
    func accentCardStyle(_ gradient: LinearGradient) -> some View {
        modifier(AccentCardStyle(gradient: gradient))
    }
}
