import SwiftUI

struct LessonCardView: View {
    let card: LessonCard
    let style: CardStyle

    enum CardStyle {
        case stacked
        case large
    }

    var body: some View {
        switch style {
        case .stacked:
            stackedCard
        case .large:
            largeCard
        }
    }

    // MARK: - Stacked Card (compact, used inside deck)

    private var stackedCard: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: card.colorHex))

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.title)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(card.subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.leading, 20)

                Spacer()

                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: card.iconSystemName)
                            .foregroundStyle(.white)
                            .font(.system(size: 14, weight: .semibold))
                    )
                    .padding(.trailing, 20)
            }
        }
        .frame(height: 80)
    }

    // MARK: - Large Card (list item with subtitle and rating)

    private var largeCard: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: card.colorHex))

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(card.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !card.description.isEmpty {
                        Text(card.description)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(card.subtitle)
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(2)
                    }

                    RatingView(rating: card.rating)
                        .padding(.top, 2)
                }

                Spacer(minLength: 12)

                Circle()
                    .fill(Color.white.opacity(0.30))
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: card.iconSystemName)
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                    )
            }
            .padding(20)
        }
    }
}

// MARK: - Decorative squiggle shape

struct CardSquiggle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY
        path.move(to: CGPoint(x: rect.minX, y: midY + 8))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: midY - 8),
            control1: CGPoint(x: rect.width * 0.3, y: rect.minY + 10),
            control2: CGPoint(x: rect.width * 0.7, y: rect.maxY - 10)
        )
        return path
    }
}

// MARK: - Star rating

struct RatingView: View {
    let rating: Int

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { index in
                Image(systemName: index < rating ? "star.fill" : "star")
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(index < rating ? 0.65 : 0.30))
            }
        }
    }
}

// MARK: - Hex color helper

extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch sanitized.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
