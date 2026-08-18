import SwiftUI

struct QuickAccessGrid: View {
    let items: [QuickAccessItem]
    let onItemTap: (QuickAccessItem) -> Void
    
    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 20
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    QuickAccessCell(item: item) {
                        onItemTap(item)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.14, green: 0.14, blue: 0.16))
        )
        .opacity(cardOpacity)
        .offset(y: cardOffset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                cardOpacity = 1.0
                cardOffset = 0
            }
        }
    }
    
    private var sectionHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            
            Text("Quick Access")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

struct QuickAccessCell: View {
    let item: QuickAccessItem
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: item.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(item.color)
                    .frame(width: 48, height: 48)

                Text(item.title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: "1C1C1E"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(hex: "2C2C2E"), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct QuickAccessItem: Identifiable, Equatable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let destination: String
    
    static let defaultItems: [QuickAccessItem] = [
        QuickAccessItem(
            id: "quiz",
            title: "Quiz",
            icon: "checkmark.circle.fill",
            color: Color(hex: "378ADD"),   // blue
            destination: "quiz_map"
        ),
        QuickAccessItem(
            id: "grammar",
            title: "Grammar",
            icon: "textformat.abc",
            color: Color(hex: "378ADD"),   // blue
            destination: "grammar"
        ),
        QuickAccessItem(
            id: "listening",
            title: "Listening",
            icon: "headphones",
            color: Color(hex: "7F77DD"),   // purple
            destination: "listening"
        ),
        QuickAccessItem(
            id: "movies",
            title: "Movies",
            icon: "film.fill",
            color: Color(hex: "EF9F27"),   // amber
            destination: "movies"
        ),
        QuickAccessItem(
            id: "stories",
            title: "Stories",
            icon: "books.vertical.fill",
            color: Color(hex: "639922"),   // green
            destination: "stories"
        ),
        QuickAccessItem(
            id: "speed",
            title: "Speed Quiz",
            icon: "bolt.fill",
            color: Color(hex: "EF9F27"),   // amber
            destination: "speed_review"
        )
    ]
}

// MARK: - ContinueJourneyCard — Fix 7 (blob removed, geometric illustration added)

struct ContinueJourneyCard: View {
    let worldName: String
    let progress: String
    let onTap: () -> Void

    @State private var cardOpacity: Double = 0
    @State private var cardOffset: CGFloat = 20

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .leading) {
                // Blue gradient background
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.216, green: 0.541, blue: 0.867),
                                Color(red: 0.14, green: 0.28, blue: 0.70)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)

                // Geometric illustration — right side
                geometricIllustration

                // Text content — left side
                contentOverlay
            }
        }
        .buttonStyle(.plain)
        .opacity(cardOpacity)
        .offset(y: cardOffset)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                cardOpacity = 1.0
                cardOffset = 0
            }
        }
    }

    private var geometricIllustration: some View {
        Image(systemName: "book.pages.fill")
            .font(.system(size: 40))
            .foregroundStyle(.white.opacity(0.25))
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 16)
    }

    private var contentOverlay: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("CONTINUE JOURNEY")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(.white.opacity(0.65))
                .tracking(1.2)

            Text(worldName)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(progress)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
    }
}
