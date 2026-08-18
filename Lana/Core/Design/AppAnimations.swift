import SwiftUI

enum AppColors {
    static let lime = LotusApp.cobalt
    static let blue = LotusApp.cobalt
    static let purple = LotusApp.violet
    static let orange = LotusApp.amber
    static let green = LotusApp.mint
    static let pink = LotusApp.coral
    static let red = LotusApp.danger
    static let gold = LotusApp.amber
    
    static let darkBg = LotusApp.pearl
    static let darkCard = Color.white.opacity(0.86)
    static let darkCardAlt = LotusApp.ink.opacity(0.055)
}

enum AppAnimations {
    static let spring = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 1
                }
            }
    }
}

struct SlideUpModifier: ViewModifier {
    @State private var offset: CGFloat = 30
    @State private var opacity: Double = 0
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    offset = 0
                    opacity = 1
                }
            }
    }
}

extension View {
    func fadeIn() -> some View {
        modifier(FadeInModifier())
    }
    
    func slideUp() -> some View {
        modifier(SlideUpModifier())
    }
}

struct PulseEffect: View {
    @State private var isAnimating = false
    
    let color: Color
    let size: CGFloat
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.3 : 1.0)
            .opacity(isAnimating ? 0 : 0.6)
            .animation(
                .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 5
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0)
        )
    }
}

extension View {
    func shake(trigger: Bool) -> some View {
        modifier(ShakeEffect(animatableData: trigger ? 1 : 0))
    }
}
