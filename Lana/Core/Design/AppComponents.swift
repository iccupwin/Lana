import SwiftUI

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var pressScale: ScaleButtonStyle { ScaleButtonStyle() }
    static func pressScale(_ scale: CGFloat) -> ScaleButtonStyle { ScaleButtonStyle(scale: scale) }
}

extension ButtonStyle where Self == BounceButtonStyle {
    static var bounce: BounceButtonStyle { BounceButtonStyle() }
}

private let limeGradient = LinearGradient(
    colors: [LotusApp.aqua, LotusApp.cobalt, LotusApp.violet],
    startPoint: .leading, endPoint: .trailing
)

struct AppCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.86))
                    .shadow(color: LotusApp.ink.opacity(0.06), radius: 16, y: 7)
            )
    }
}

struct AppButton: View {
    enum Style {
        case primary, secondary, outline, ghost
    }
    
    let title: String
    let style: Style
    let icon: String?
    let action: () -> Void
    
    init(
        _ title: String,
        style: Style = .primary,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(background)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(border, lineWidth: style == .outline ? 2 : 0)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            LotusApp.aurora
        case .secondary:
            Color.white.opacity(0.86)
        case .outline, .ghost:
            Color.clear
        }
    }
    
    private var foreground: Color {
        switch style {
        case .primary:
            return Color.white
        case .secondary, .outline, .ghost:
            return LotusApp.ink
        }
    }
    
    private var border: Color {
        switch style {
        case .outline:
            return LotusApp.cobalt
        default:
            return Color.clear
        }
    }
}

struct AppIconButton: View {
    let icon: String
    let color: Color
    let size: CGFloat
    let action: () -> Void
    
    init(
        _ icon: String,
        color: Color = LotusApp.ink,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.color = color
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.88))
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct AppProgressBar: View {
    let progress: Double
    let height: CGFloat
    let gradient: LinearGradient
    
    init(
        progress: Double,
        height: CGFloat = 8,
        gradient: LinearGradient? = nil
    ) {
        self.progress = progress
        self.height = height
        self.gradient = gradient ?? limeGradient
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LotusApp.ink.opacity(0.065))
                    .frame(height: height)
                
                Capsule()
                    .fill(gradient)
                    .frame(width: geo.size.width * min(1, max(0, progress)), height: height)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}

struct AppBadge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}

struct AppStatBox: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            
            Text(label)
                .font(.system(size: 11))
                .foregroundStyle(LotusApp.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.12))
        )
    }
}

struct AppXPCount: View {
    let amount: Int
    let size: CGFloat
    
    init(_ amount: Int, size: CGFloat = 16) {
        self.amount = amount
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.7, weight: .bold))
                .foregroundStyle(LotusApp.cobalt)
            
            Text("\(amount)")
                .font(.system(size: size, weight: .black, design: .rounded))
                .foregroundStyle(LotusApp.ink)
        }
    }
}
