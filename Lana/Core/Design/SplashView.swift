import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var logoOpacity: Double = 0
    
    var body: some View {
        ZStack {
            LotusApp.pearl.ignoresSafeArea()
            Image("LotusAuroraBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.42)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LotusApp.softAurora)
                        .frame(width: 140, height: 140)
                        .scaleEffect(scale)
                        .opacity(opacity)
                    
                    Circle()
                        .fill(Color.white.opacity(0.74))
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale * 0.9)
                        .opacity(opacity)
                    
                    Image("LotusBloom")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 112, height: 112)
                        .opacity(logoOpacity)
                }
                
                Text("English, in full bloom")
                    .font(.system(size: 25, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                    .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .spring(response: 0.6, dampingFraction: 0.65)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                logoOpacity = 1.0
            }
        }
    }
}

struct AnimatedLogo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LotusApp.cobalt.opacity(0.22),
                    lineWidth: 2
                )
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(rotation))
            
            Image(systemName: "camera.macro")
                .font(.system(size: 32, weight: .semibold))
                .foregroundStyle(LotusApp.aurora)
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .linear(duration: 8).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}
