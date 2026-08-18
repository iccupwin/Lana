import SwiftUI

// MARK: - Level-Up Celebration Overlay

struct LevelUpCelebrationView: View {
    let levelInfo: LevelInfo
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Confetti
            LevelUpConfettiView()

            // Celebration card
            VStack(spacing: 24) {
                // Trophy glow
                ZStack {
                    Circle()
                        .fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.18))
                        .frame(width: 160, height: 160)
                    Circle()
                        .fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.32))
                        .frame(width: 110, height: 110)
                    Image(systemName: levelInfo.icon)
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                }

                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                        .tracking(3)

                    Text("Level \(levelInfo.level)")
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)

                    Text(levelInfo.name)
                        .font(.system(size: 22, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Button { dismiss() } label: {
                    Text("Continue  →")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.lime))
                }
                .buttonStyle(PressScaleStyle())
                .padding(.horizontal, 4)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(DarkDS.card)
                    .overlay(RoundedRectangle(cornerRadius: 32).strokeBorder(DarkDS.border, lineWidth: 1))
            )
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            HapticService.shared.notify(.success)
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            scale = 0.85
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
    }
}

// MARK: - Confetti

private struct ConfettiPieceData {
    let xFrac:    CGFloat
    let delay:    Double
    let w:        CGFloat
    let h:        CGFloat
    let colorIdx: Int
}

private func makePieces() -> [ConfettiPieceData] {
    (0..<60).map { i in
        let xFrac:    CGFloat = CGFloat(i) / 60.0 + CGFloat.random(in: -0.015...0.015)
        let delay:    Double  = Double(i % 12) * 0.08 + Double.random(in: 0...0.4)
        let w:        CGFloat = CGFloat.random(in: 7...14)
        let h:        CGFloat = CGFloat.random(in: 5...10)
        return ConfettiPieceData(xFrac: xFrac, delay: delay, w: w, h: h, colorIdx: i % 8)
    }
}

private struct LevelUpConfettiView: View {

    private static let pieces: [ConfettiPieceData] = makePieces()

    private let palette: [Color] = [
        .yellow, .orange, .green, Color(red: 0.4, green: 0.65, blue: 1),
        .pink, .purple, Color.red.opacity(0.8), .cyan
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Self.pieces.indices, id: \.self) { i in
                let p = Self.pieces[i]
                LevelUpFallingPiece(
                    startX: geo.size.width * p.xFrac,
                    fallTo: geo.size.height + 80,
                    w: p.w, h: p.h,
                    color: palette[p.colorIdx],
                    delay: p.delay
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

private struct LevelUpFallingPiece: View {
    let startX: CGFloat
    let fallTo:  CGFloat
    let w: CGFloat
    let h: CGFloat
    let color: Color
    let delay: Double

    @State private var yOff:     CGFloat = 0
    @State private var rotation: Double  = 0
    @State private var alpha:    Double  = 0

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: w, height: h)
            .rotationEffect(.degrees(rotation))
            .offset(x: startX, y: yOff - 20)
            .opacity(alpha)
            .onAppear {
                withAnimation(.easeOut(duration: 0.25).delay(delay)) { alpha = 1 }
                withAnimation(.linear(duration: 2.4).delay(delay)) {
                    yOff = fallTo
                    rotation = Double.random(in: -720...720)
                }
                withAnimation(.linear(duration: 0.5).delay(delay + 1.7)) { alpha = 0 }
            }
    }
}
