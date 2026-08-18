import SwiftUI

enum LotusApp {
    static let ink = Color(red: 0.045, green: 0.085, blue: 0.235)
    static let muted = Color(red: 0.37, green: 0.42, blue: 0.58)
    static let subtle = Color(red: 0.72, green: 0.75, blue: 0.84)
    static let pearl = Color(red: 0.988, green: 0.992, blue: 1.0)
    static let aqua = Color(red: 0.08, green: 0.73, blue: 0.95)
    static let cobalt = Color(red: 0.13, green: 0.34, blue: 0.98)
    static let violet = Color(red: 0.49, green: 0.28, blue: 0.98)
    static let coral = Color(red: 0.96, green: 0.31, blue: 0.67)
    static let mint = Color(red: 0.20, green: 0.72, blue: 0.57)
    static let amber = Color(red: 0.96, green: 0.55, blue: 0.20)
    static let danger = Color(red: 0.93, green: 0.29, blue: 0.39)

    static let aurora = LinearGradient(
        colors: [aqua, cobalt, violet, coral],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let softAurora = LinearGradient(
        colors: [aqua.opacity(0.16), violet.opacity(0.12), coral.opacity(0.10)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct LotusAppScreen<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                ZStack {
                    LotusApp.pearl

                    Image("LotusAuroraBackground")
                        .resizable()
                        .scaledToFill()
                        .opacity(0.38)

                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.72),
                            Color.white.opacity(0.20),
                            Color.white.opacity(0.52)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea()
            }
            .preferredColorScheme(.light)
    }
}

struct LotusGlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let opacity: Double
    let shadow: Double

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(opacity))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.96), lineWidth: 1)
                    }
                    .shadow(color: LotusApp.ink.opacity(shadow), radius: 18, y: 8)
            }
    }
}

extension View {
    func lotusGlassCard(
        cornerRadius: CGFloat = 22,
        opacity: Double = 0.82,
        shadow: Double = 0.07
    ) -> some View {
        modifier(LotusGlassCardModifier(
            cornerRadius: cornerRadius,
            opacity: opacity,
            shadow: shadow
        ))
    }
}

struct LotusPageHeader: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?
    let actionIcon: String?
    var action: (() -> Void)?

    init(
        eyebrow: String? = nil,
        title: String,
        subtitle: String? = nil,
        actionIcon: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.eyebrow = eyebrow
        self.title = title
        self.subtitle = subtitle
        self.actionIcon = actionIcon
        self.action = action
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if let eyebrow {
                    Text(eyebrow.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .tracking(1.6)
                        .foregroundStyle(LotusApp.muted)
                }

                Text(title)
                    .font(.system(size: 31, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
            }

            Spacer(minLength: 12)

            if let actionIcon, let action {
                Button(action: action) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(LotusApp.aurora)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Color.white.opacity(0.88)))
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                        .shadow(color: LotusApp.violet.opacity(0.14), radius: 12, y: 5)
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }
}

struct LotusDetailHeader: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    var subtitle: String? = nil
    var icon: String? = nil
    var color: Color = LotusApp.cobalt

    var body: some View {
        HStack(spacing: 13) {
            Button {
                HapticService.shared.selection()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(Color.white.opacity(0.90)))
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .shadow(color: LotusApp.ink.opacity(0.07), radius: 10, y: 4)
            }
            .buttonStyle(PressScaleStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 25, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(LotusApp.muted)
                }
            }

            Spacer(minLength: 8)

            if let icon {
                LotusIconBadge(icon: icon, color: color, size: 42)
                    .background(Circle().fill(Color.white.opacity(0.74)))
                    .clipShape(Circle())
            }
        }
    }
}

struct LotusCollectionHero: View {
    let imageName: String
    let title: String
    let subtitle: String
    var height: CGFloat = 180

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LotusAssetSurface(name: imageName, height: height, cornerRadius: 25)
                .opacity(0.93)

            LinearGradient(
                colors: [.clear, Color.white.opacity(0.34), Color.white.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(LotusApp.muted)
            }
            .padding(16)
        }
        .frame(height: height)
        .lotusGlassCard(cornerRadius: 25, opacity: 0.74, shadow: 0.055)
    }
}

struct LotusStatusPill: View {
    let text: String
    var color: Color = LotusApp.cobalt
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text)
        }
        .font(.system(size: 9, weight: .semibold, design: .rounded))
        .foregroundStyle(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(color.opacity(0.09)))
    }
}

struct LotusSectionTitle: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.cobalt)
            }
        }
    }
}

struct LotusProgressBar: View {
    let progress: Double
    var height: CGFloat = 7

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(LotusApp.ink.opacity(0.065))
                Capsule()
                    .fill(LotusApp.aurora)
                    .frame(width: proxy.size.width * min(1, max(0, progress)))
                    .animation(.spring(response: 0.7, dampingFraction: 0.82), value: progress)
            }
        }
        .frame(height: height)
    }
}

struct LotusGradientButton: View {
    let title: String
    var icon: String = "arrow.right"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                RoundedRectangle(cornerRadius: 17, style: .continuous)
                    .fill(LotusApp.aurora)
                    .overlay {
                        RoundedRectangle(cornerRadius: 17, style: .continuous)
                            .stroke(Color.white.opacity(0.76), lineWidth: 1)
                    }
                    .shadow(color: LotusApp.violet.opacity(0.24), radius: 14, y: 7)
            }
        }
        .buttonStyle(PressScaleStyle())
    }
}

struct LotusIconBadge: View {
    let icon: String
    var color: Color = LotusApp.cobalt
    var size: CGFloat = 42

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.10))
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: size * 0.38, weight: .semibold))
                .foregroundStyle(color)
        }
    }
}

struct LotusAssetSurface: View {
    let name: String
    var height: CGFloat
    var cornerRadius: CGFloat = 24

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(LotusApp.pearl)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
