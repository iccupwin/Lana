import SwiftUI

// MARK: - Main View

struct MatchMadnessView: View {
    @StateObject private var vm = MatchMadnessViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let cols = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

    var body: some View {
        DarkScreen {
            if vm.isFinished {
                finishedView
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                VStack(spacing: 0) {
                    header
                    timerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    if vm.combo >= 2 {
                        comboBadge
                            .padding(.top, 10)
                            .transition(.scale.combined(with: .opacity))
                    }

                    LazyVGrid(columns: cols, spacing: 10) {
                        ForEach(vm.cards) { card in
                            MatchCardView(card: card) { vm.tap(card) }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()

                    // Hint legend
                    HStack(spacing: 16) {
                        legendDot(color: DarkDS.card, label: "English")
                        legendDot(color: Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.55), label: "Russian")
                    }
                    .padding(.bottom, 36)
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.isFinished)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.combo)
        .onDisappear {
            if !vm.isFinished { vm.finish() }
        }
        .onChange(of: vm.isFinished) { finished in
            if finished {
                appState.triggerAchievement("first_match_madness")
                appState.checkAchievements()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(DarkDS.card)
                        .frame(width: 40, height: 40)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                }
            }
            .buttonStyle(PressScaleStyle())

            Spacer()

            VStack(spacing: 2) {
                Text("MATCH MADNESS")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("\(vm.score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: vm.score)
            }

            Spacer()

            // Matched pairs counter
            VStack(spacing: 2) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                Text("\(vm.matchedPairsTotal)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            .frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    // MARK: - Timer Bar

    private var timerBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(DarkDS.card2)
                    .frame(height: 8)
                RoundedRectangle(cornerRadius: 5)
                    .fill(vm.timeLeft > 15
                          ? Color(red: 0.20, green: 0.78, blue: 0.43)
                          : Color.red.opacity(0.75))
                    .frame(width: geo.size.width * min(1, vm.timeLeft / 60), height: 8)
                    .animation(.linear(duration: 0.05), value: vm.timeLeft)
            }
        }
        .frame(height: 8)
    }

    // MARK: - Combo Badge

    private var comboBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 11))
                .foregroundStyle(.white)
            Text("COMBO ×\(vm.combo)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color(red: 0.98, green: 0.79, blue: 0.20)))
    }

    // MARK: - Legend

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 3).fill(color).frame(width: 14, height: 14)
                .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(DarkDS.border, lineWidth: 1))
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
        }
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle().fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.2)).frame(width: 140, height: 140)
                Circle().fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.45)).frame(width: 100, height: 100)
                Image(systemName: vm.matchedPairsTotal >= 15 ? "trophy.fill" : vm.matchedPairsTotal >= 8 ? "star.fill" : "target")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            }

            VStack(spacing: 8) {
                Text("Time's Up!")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text("You matched \(vm.matchedPairsTotal) pairs")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }

            HStack(spacing: 10) {
                finStat(label: "Score",   value: "\(vm.score)",             icon: "star.fill",             color: Color(red: 0.98, green: 0.79, blue: 0.20))
                finStat(label: "XP",      value: "+\(vm.xpEarned)",         icon: "bolt.fill",             color: Color(red: 0.20, green: 0.78, blue: 0.43))
                finStat(label: "Pairs",   value: "\(vm.matchedPairsTotal)", icon: "checkmark.circle.fill", color: Color(red: 0.62, green: 0.38, blue: 0.98))
            }
            .padding(.horizontal, 20)

            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 24)

            Spacer()
        }
    }

    private func finStat(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 14)).foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Text(label).font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(DarkDS.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(color.opacity(0.2)))
    }
}

// MARK: - Card View

struct MatchCardView: View {
    let card: MatchCard
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(card.text)
                .font(.system(
                    size: card.isEnglish ? 14 : 13,
                    weight: .medium,
                    design: card.isEnglish ? .rounded : .default
                ))
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
                .frame(maxWidth: .infinity, minHeight: 64)
                .padding(.horizontal, 6)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(bgColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(borderColor, lineWidth: 1.5)
                )
                .scaleEffect(card.state == .matched ? 0.7 : (card.state == .selected ? 1.04 : 1.0))
                .opacity(card.state == .matched ? 0 : 1)
        }
        .buttonStyle(.plain)
        .disabled(card.state == .matched)
        .animation(.spring(response: 0.28, dampingFraction: 0.65), value: card.state)
    }

    private var bgColor: Color {
        switch card.state {
        case .idle:     return card.isEnglish ? DarkDS.card : Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.28)
        case .selected: return card.isEnglish ? Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.45) : Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.65)
        case .matched:  return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.35)
        case .wrong:    return Color.red.opacity(0.13)
        }
    }

    private var textColor: Color {
        switch card.state {
        case .wrong:    return Color.red
        case .matched:  return Color(red: 0.20, green: 0.78, blue: 0.43)
        default:        return LotusApp.ink
        }
    }

    private var borderColor: Color {
        switch card.state {
        case .selected: return card.isEnglish ? Color(red: 0.98, green: 0.79, blue: 0.20) : Color(red: 0.22, green: 0.44, blue: 0.98)
        case .wrong:    return Color.red.opacity(0.35)
        case .matched:  return Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.4)
        default:        return Color.clear
        }
    }
}
