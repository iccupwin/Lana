import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [
        Color(red: 0.98, green: 0.79, blue: 0.20),
        Color(red: 0.20, green: 0.78, blue: 0.43),
        Color(red: 0.62, green: 0.38, blue: 0.98),
        Color(red: 0.98, green: 0.55, blue: 0.20),
        Color(red: 0.22, green: 0.44, blue: 0.98),
        Color(red: 0.98, green: 0.30, blue: 0.60),
    ]

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for particle in particles {
                        let elapsed = now - particle.startTime
                        guard elapsed >= 0 else { continue }
                        let progress = min(elapsed / particle.duration, 1.0)
                        let x = particle.x * size.width + particle.velocityX * elapsed * size.width
                        let y = particle.startY * size.height + progress * size.height * 1.2 + sin(elapsed * particle.wobble) * 20
                        let opacity = max(0, 1 - progress * 1.2)
                        let rotation = Angle(degrees: elapsed * particle.rotationSpeed)
                        var ctx = context
                        ctx.opacity = opacity
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: rotation)
                        let rect = CGRect(x: -particle.size / 2, y: -particle.size / 2, width: particle.size, height: particle.size * 0.6)
                        if particle.isCircle {
                            ctx.fill(Path(ellipseIn: rect), with: .color(particle.color))
                        } else {
                            ctx.fill(Path(rect), with: .color(particle.color))
                        }
                    }
                }
            }
        }
        .onAppear { spawn() }
        .allowsHitTesting(false)
    }

    private func spawn() {
        let now = Date.timeIntervalSinceReferenceDate
        particles = (0..<80).map { i in
            ConfettiParticle(
                x: Double.random(in: 0.05...0.95),
                startY: Double.random(in: -0.3...0.1),
                velocityX: Double.random(in: -0.08...0.08),
                duration: Double.random(in: 1.8...3.2),
                size: Double.random(in: 6...14),
                color: colors.randomElement()!,
                rotationSpeed: Double.random(in: 120...480) * (Bool.random() ? 1 : -1),
                wobble: Double.random(in: 2...5),
                isCircle: Bool.random(),
                startTime: now + Double(i) * 0.02
            )
        }
    }
}

struct ConfettiParticle {
    let x: Double
    let startY: Double
    let velocityX: Double
    let duration: Double
    let size: Double
    let color: Color
    let rotationSpeed: Double
    let wobble: Double
    let isCircle: Bool
    let startTime: Double
}
