import SwiftUI

enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 48
    
    static let cornerRadiusSm: CGFloat = 12
    static let cornerRadiusMd: CGFloat = 16
    static let cornerRadiusLg: CGFloat = 20
    static let cornerRadiusXl: CGFloat = 24
}

enum AppTypography {
    static func largeTitle(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func title1(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func title2(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 22, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func headline(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func body(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 15, weight: .regular, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func callout(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func subheadline(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func footnote(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundStyle(color)
    }
    
    static func caption(_ color: Color = .primary) -> some View {
        Text("")
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(color)
    }
}

struct AppText: View {
    enum Style {
        case largeTitle, title1, title2, headline, body, callout, subheadline, footnote, caption
    }
    
    let text: String
    let style: Style
    let color: Color
    
    init(_ text: String, style: Style, color: Color = .primary) {
        self.text = text
        self.style = style
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
    }
    
    private var font: Font {
        switch style {
        case .largeTitle: return .system(size: 32, weight: .bold, design: .rounded)
        case .title1: return .system(size: 28, weight: .bold, design: .rounded)
        case .title2: return .system(size: 22, weight: .semibold, design: .rounded)
        case .headline: return .system(size: 17, weight: .semibold, design: .rounded)
        case .body: return .system(size: 15, weight: .regular, design: .rounded)
        case .callout: return .system(size: 14, weight: .medium, design: .rounded)
        case .subheadline: return .system(size: 13, weight: .regular, design: .rounded)
        case .footnote: return .system(size: 12, weight: .regular, design: .rounded)
        case .caption: return .system(size: 11, weight: .medium, design: .rounded)
        }
    }
}
