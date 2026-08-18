import SwiftUI

// ✓ implements: Duolingo — Visual Skill Path Preview on Home Screen

/// Compact horizontal preview of the current quiz world's stages.
/// Shows up to 5 nodes (completed, current, locked) connected by a line —
/// identical visual language to the full QuizMapView but trimmed to fit home.
struct SkillPathPreviewCard: View {
    let world: QuizWorld
    let onNodeTap: (QuizStage) -> Void
    let onSeeAll: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ── Header ──────────────────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("YOUR PATH")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundStyle(world.accentColor.opacity(0.8))
                        .tracking(1.4)
                    Text(world.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Button(action: onSeeAll) {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(world.accentColor)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(world.accentColor)
                    }
                }
                .buttonStyle(.plain)
            }

            // ── Node row ────────────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(world.stages.enumerated()), id: \.element.id) { idx, stage in
                        HStack(spacing: 0) {
                            // Connector line (not before first node)
                            if idx > 0 {
                                connectorLine(stage: stage, prev: world.stages[idx - 1])
                            }
                            // Node
                            PathNode(
                                stage: stage,
                                accentColor: world.accentColor,
                                gradient: world.gradient,
                                isCurrent: isCurrent(stage)
                            )
                            .onTapGesture {
                                guard stage.isUnlocked else { return }
                                HapticService.shared.selection()
                                onNodeTap(stage)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }

            // ── World progress bar ────────────────────────────────────
            VStack(spacing: 4) {
                HStack {
                    Text("\(world.completedStages) of \(world.stages.count) stages complete")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(DarkDS.muted)
                    Spacer()
                    Text("\(Int(worldFraction * 100))%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(world.accentColor)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(DarkDS.card2).frame(height: 4)
                        Capsule()
                            .fill(world.gradient)
                            .frame(width: geo.size.width * (appeared ? worldFraction : 0), height: 4)
                            .animation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.3), value: appeared)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
        .onAppear { appeared = true }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Skill path: \(world.name), \(world.completedStages) of \(world.stages.count) stages complete")
    }

    // MARK: - Helpers

    private var worldFraction: CGFloat {
        guard world.stages.count > 0 else { return 0 }
        return CGFloat(world.completedStages) / CGFloat(world.stages.count)
    }

    private func isCurrent(_ stage: QuizStage) -> Bool {
        stage.isUnlocked && stage.bestStars == 0
            && !world.stages.filter { $0.isUnlocked && $0.bestStars == 0 }.isEmpty
            && world.stages.filter { $0.isUnlocked && $0.bestStars == 0 }.first?.id == stage.id
    }

    @ViewBuilder
    private func connectorLine(stage: QuizStage, prev: QuizStage) -> some View {
        let bothDone = prev.bestStars > 0
        Rectangle()
            .fill(
                bothDone
                    ? AnyShapeStyle(world.gradient)
                    : AnyShapeStyle(DarkDS.card2)
            )
            .frame(width: 24, height: 3)
            .offset(y: -10) // align with center of 52pt node
    }
}

// MARK: - PathNode

private struct PathNode: View {
    let stage: QuizStage
    let accentColor: Color
    let gradient: LinearGradient
    let isCurrent: Bool

    @State private var pulse = false
    private let gold = Color(red: 0.98, green: 0.79, blue: 0.20)
    private let nodeSize: CGFloat = 52

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Pulse ring for the active stage
                if isCurrent {
                    Circle()
                        .stroke(accentColor.opacity(0.25), lineWidth: 5)
                        .frame(width: nodeSize + 14, height: nodeSize + 14)
                        .scaleEffect(pulse ? 1.18 : 1.0)
                        .opacity(pulse ? 0 : 0.7)
                        .animation(
                            .easeInOut(duration: 1.2).repeatForever(autoreverses: false),
                            value: pulse
                        )
                        .onAppear { pulse = true }
                }

                // Node circle background
                Circle()
                    .fill(nodeFill)
                    .frame(width: nodeSize, height: nodeSize)
                    .overlay(
                        Circle().strokeBorder(nodeBorder, lineWidth: 2)
                    )

                // Icon
                nodeIcon
            }

            // Stars
            HStack(spacing: 3) {
                ForEach(1...3, id: \.self) { i in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(i <= stage.bestStars ? gold : DarkDS.card2)
                }
            }

            // "PLAY" label for current stage
            if isCurrent {
                Text("PLAY")
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .foregroundStyle(accentColor)
                    .tracking(1.0)
            }
        }
        .frame(width: 70)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(stage.isUnlocked ? [.isButton] : [])
    }

    // MARK: Styling

    private var nodeFill: AnyShapeStyle {
        if !stage.isUnlocked { return AnyShapeStyle(DarkDS.card) }
        if stage.bestStars == 3 { return AnyShapeStyle(gradient) }
        if stage.bestStars > 0 { return AnyShapeStyle(accentColor.opacity(0.45)) }
        return AnyShapeStyle(DarkDS.bg)
    }

    private var nodeBorder: Color {
        if !stage.isUnlocked { return DarkDS.card2 }
        if stage.bestStars == 3 { return gold.opacity(0.5) }
        if stage.bestStars > 0 { return accentColor.opacity(0.6) }
        return accentColor
    }

    @ViewBuilder
    private var nodeIcon: some View {
        if !stage.isUnlocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(DarkDS.muted)
        } else if stage.bestStars == 3 {
            Image(systemName: "star.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(gold)
        } else if stage.bestStars > 0 {
            Image(systemName: "checkmark")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        } else {
            Image(systemName: "pencil.and.list.clipboard")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accentColor)
        }
    }

    private var accessibilityLabel: String {
        let state = stage.isUnlocked
            ? (stage.bestStars > 0 ? "\(stage.bestStars) stars earned" : "ready to play")
            : "locked"
        return "\(stage.title), stage \(stage.stageNumber), \(state)"
    }
}

// MARK: - Preview

#Preview {
    let worlds = QuizMapConfig.makeWorlds(bestStars: ["quiz_basic": 3, "quiz_travel": 2])
    return SkillPathPreviewCard(
        world: worlds[0],
        onNodeTap: { _ in },
        onSeeAll: {}
    )
    .padding(20)
    .background(DarkDS.bg)
}
