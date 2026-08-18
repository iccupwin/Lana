import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentStep = 0
    @State private var notificationsToggle: Bool
    @State private var artIsAlive = false

    private let totalSteps = 4

    private let cefrLevels: [(code: String, name: String)] = [
        ("A1", "Beginner"),
        ("A2", "Elementary"),
        ("B1", "Intermediate"),
        ("B2", "Upper-Intermediate"),
        ("C1", "Advanced"),
        ("C2", "Proficient")
    ]

    private let goalOptions: [(minutes: Int, label: String)] = [
        (5, "Light"),
        (10, "Balanced"),
        (20, "Focused")
    ]

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        _notificationsToggle = State(
            initialValue: UserDefaults.standard.bool(forKey: "notificationsEnabled")
        )
    }

    var body: some View {
        GeometryReader { proxy in
            let isCompact = proxy.size.height < 760

            VStack(spacing: 0) {
                dotsIndicator
                    .padding(.top, 12)
                    .padding(.bottom, isCompact ? 8 : 14)

                ScrollView(.vertical, showsIndicators: false) {
                    stepContent(isCompact: isCompact)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 12)
                        .id(currentStep)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                }
                .scrollBounceBehavior(.basedOnSize)

                continueButton
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 12)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .simultaneousGesture(backSwipeGesture)
        }
        .background {
            onboardingBackground
                .ignoresSafeArea()
        }
        .preferredColorScheme(.light)
        .onAppear {
            startArtAnimation()
        }
        .onChange(of: currentStep) { _ in
            startArtAnimation()
        }
    }

    // MARK: - Background and navigation

    private var onboardingBackground: some View {
        ZStack {
            Color.white

            Image("LotusAuroraBackground")
                .resizable()
                .scaledToFill()
                .opacity(0.86)

            LinearGradient(
                colors: [
                    Color.white.opacity(0.54),
                    Color.white.opacity(0.06),
                    Color.white.opacity(0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .clipped()
    }

    private var dotsIndicator: some View {
        HStack(spacing: 9) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index == currentStep ? LotusPalette.cobalt : LotusPalette.dot)
                    .frame(width: index == currentStep ? 20 : 7, height: 7)
                    .shadow(
                        color: index == currentStep ? LotusPalette.cobalt.opacity(0.32) : .clear,
                        radius: 6,
                        y: 2
                    )
                    .animation(.spring(response: 0.38, dampingFraction: 0.72), value: currentStep)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep + 1) of \(totalSteps)")
    }

    @ViewBuilder
    private func stepContent(isCompact: Bool) -> some View {
        switch currentStep {
        case 0:
            welcomeStep(isCompact: isCompact)
        case 1:
            levelStep(isCompact: isCompact)
        case 2:
            rhythmStep(isCompact: isCompact)
        case 3:
            reminderStep(isCompact: isCompact)
        default:
            EmptyView()
        }
    }

    // MARK: - Step 1: Bloom

    private func welcomeStep(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 18) {
            screenHeading(
                "English,\nmade personal",
                subtitle: "Your daily guide to confident English",
                isCompact: isCompact
            )

            Image("LotusBloom")
                .resizable()
                .scaledToFit()
                .frame(height: isCompact ? 235 : 292)
                .scaleEffect(artIsAlive ? 1 : 0.91)
                .offset(y: artIsAlive ? -3 : 5)
                .shadow(color: LotusPalette.violet.opacity(0.17), radius: 24, y: 14)
                .animation(artFloatAnimation, value: artIsAlive)
                .accessibilityHidden(true)

            HStack(spacing: 9) {
                featureChip(icon: "bubble.left.and.bubble.right.fill", text: "Speak\nnaturally")
                featureChip(icon: "brain.head.profile", text: "Remember\nmore")
                featureChip(icon: "scope", text: "Stay\nconsistent")
            }
        }
        .padding(.top, isCompact ? 4 : 10)
    }

    private func featureChip(icon: String, text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(LotusPalette.buttonGradient)
                .frame(height: 24)

            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(LotusPalette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 78)
        .padding(.horizontal, 6)
        .background(glassCard(cornerRadius: 18))
    }

    // MARK: - Step 2: Petals and levels

    private func levelStep(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 12 : 16) {
            screenHeading(
                "Where are you now?",
                subtitle: "Choose the level that feels closest",
                isCompact: isCompact
            )

            ZStack(alignment: .leading) {
                Image("LotusLevelTrail")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isCompact ? 135 : 158)
                    .opacity(0.52)
                    .offset(x: -48, y: artIsAlive ? -2 : 6)
                    .animation(artFloatAnimation, value: artIsAlive)
                    .accessibilityHidden(true)

                VStack(spacing: isCompact ? 7 : 9) {
                    ForEach(cefrLevels, id: \.code) { level in
                        levelButton(level)
                    }
                }
                .padding(.leading, 19)
            }
        }
        .padding(.top, isCompact ? 2 : 8)
    }

    private func levelButton(_ level: (code: String, name: String)) -> some View {
        let isSelected = viewModel.selectedCEFR == level.code

        return Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.72)) {
                viewModel.selectedCEFR = level.code
            }
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? LotusPalette.selectedTokenGradient
                                : LotusPalette.inactiveTokenGradient
                        )
                        .frame(width: 47, height: 47)
                        .shadow(
                            color: isSelected ? LotusPalette.cobalt.opacity(0.28) : .clear,
                            radius: 9,
                            y: 4
                        )

                    Text(level.code)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.white : LotusPalette.cobalt)
                }

                Text(level.name)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(LotusPalette.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 8)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(LotusPalette.buttonGradient)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(levelCardBackground(isSelected: isSelected))
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(level.code), \(level.name)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }

    private func levelCardBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(isSelected ? 0.92 : 0.79))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? LotusPalette.cobalt.opacity(0.94) : Color.white.opacity(0.9),
                        lineWidth: isSelected ? 1.7 : 1
                    )
            }
            .shadow(
                color: isSelected ? LotusPalette.violet.opacity(0.18) : LotusPalette.ink.opacity(0.055),
                radius: isSelected ? 14 : 8,
                y: isSelected ? 6 : 4
            )
    }

    // MARK: - Step 3: Lotus rhythm

    private func rhythmStep(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 8 : 14) {
            screenHeading(
                "Choose your\ndaily rhythm",
                subtitle: "You can change this anytime",
                isCompact: isCompact
            )

            ZStack {
                Image("LotusRhythm")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isCompact ? 330 : 370, height: isCompact ? 330 : 370)
                    .rotationEffect(.degrees(artIsAlive ? 1.8 : -1.8))
                    .scaleEffect(artIsAlive ? 1 : 0.97)
                    .animation(artFloatAnimation, value: artIsAlive)
                    .accessibilityHidden(true)

                rhythmOption(goalOptions[0], selected: viewModel.dailyMinuteGoal == 5)
                    .offset(x: isCompact ? -100 : -112, y: isCompact ? -92 : -104)

                rhythmOption(goalOptions[1], selected: viewModel.dailyMinuteGoal == 10)
                    .offset(x: isCompact ? 100 : 112, y: isCompact ? -6 : -8)

                rhythmOption(goalOptions[2], selected: viewModel.dailyMinuteGoal == 20)
                    .offset(x: 0, y: isCompact ? 112 : 126)
            }
            .frame(height: isCompact ? 338 : 390)
        }
        .padding(.top, isCompact ? 0 : 6)
    }

    private func rhythmOption(_ option: (minutes: Int, label: String), selected: Bool) -> some View {
        Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.7)) {
                viewModel.dailyMinuteGoal = option.minutes
            }
        } label: {
            VStack(spacing: 0) {
                Text("\(option.minutes)")
                    .font(.system(size: selected ? 30 : 23, weight: .medium, design: .rounded))
                Text("min")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                Text(option.label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .padding(.top, 2)
            }
            .foregroundStyle(selected ? LotusPalette.ink : LotusPalette.cobalt)
            .frame(width: selected ? 98 : 82, height: selected ? 98 : 82)
            .background {
                Circle()
                    .fill(Color.white.opacity(selected ? 0.96 : 0.87))
                    .overlay {
                        Circle()
                            .stroke(
                                selected ? LotusPalette.violet : LotusPalette.aqua.opacity(0.74),
                                lineWidth: selected ? 2.2 : 1.2
                            )
                    }
                    .shadow(
                        color: selected ? LotusPalette.violet.opacity(0.28) : LotusPalette.aqua.opacity(0.12),
                        radius: selected ? 17 : 9,
                        y: 5
                    )
            }
        }
        .buttonStyle(PressScaleStyle())
        .accessibilityLabel("\(option.minutes) minutes, \(option.label)")
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    // MARK: - Step 4: Reminder bud

    private func reminderStep(isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 10 : 16) {
            screenHeading(
                "Keep your\nmomentum",
                subtitle: "A gentle reminder protects your progress",
                isCompact: isCompact
            )

            Image("LotusReminder")
                .resizable()
                .scaledToFit()
                .frame(height: isCompact ? 230 : 282)
                .scaleEffect(artIsAlive ? 1 : 0.94)
                .offset(y: artIsAlive ? -2 : 4)
                .shadow(color: LotusPalette.violet.opacity(0.15), radius: 22, y: 10)
                .animation(artFloatAnimation, value: artIsAlive)
                .accessibilityHidden(true)

            HStack(spacing: 10) {
                benefitCard(icon: "leaf.fill", text: "Smart\nreminders")
                benefitCard(icon: "calendar", text: "Designed around\nyour schedule")
            }

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LotusPalette.aqua.opacity(0.11))
                        .frame(width: 38, height: 38)
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(LotusPalette.buttonGradient)
                }

                Text("Daily reminder")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(LotusPalette.ink)

                Spacer()

                Toggle("Daily reminder", isOn: $notificationsToggle)
                    .labelsHidden()
                    .tint(LotusPalette.cobalt)
                    .onChange(of: notificationsToggle) { enabled in
                        updateNotificationPreference(enabled)
                    }
            }
            .padding(.horizontal, 14)
            .frame(minHeight: 62)
            .background(glassCard(cornerRadius: 19))
        }
        .padding(.top, isCompact ? 0 : 6)
    }

    private func benefitCard(icon: String, text: String) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(LotusPalette.buttonGradient)
                .frame(width: 25)

            Text(text)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(LotusPalette.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, minHeight: 66)
        .background(glassCard(cornerRadius: 18))
    }

    // MARK: - Shared UI

    private func screenHeading(_ title: String, subtitle: String, isCompact: Bool) -> some View {
        VStack(spacing: isCompact ? 6 : 8) {
            Text(title)
                .font(.system(size: isCompact ? 29 : 34, weight: .regular, design: .serif))
                .foregroundStyle(LotusPalette.ink)
                .multilineTextAlignment(.center)
                .lineSpacing(-2)
                .minimumScaleFactor(0.82)

            Text(subtitle)
                .font(.system(size: isCompact ? 13 : 15, weight: .regular, design: .rounded))
                .foregroundStyle(LotusPalette.muted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.84)
        }
        .accessibilityElement(children: .combine)
    }

    private func glassCard(cornerRadius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white.opacity(0.78))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.94), lineWidth: 1)
            }
            .shadow(color: LotusPalette.ink.opacity(0.06), radius: 11, y: 5)
    }

    private var continueButton: some View {
        Button(action: advance) {
            HStack(spacing: 9) {
                Text(primaryButtonTitle)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))

                Image(systemName: currentStep == totalSteps - 1 ? "sparkles" : "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LotusPalette.buttonGradient)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.72), lineWidth: 1)
                    }
                    .shadow(color: LotusPalette.violet.opacity(0.28), radius: 16, y: 8)
            }
        }
        .buttonStyle(PressScaleStyle())
    }

    private var primaryButtonTitle: String {
        switch currentStep {
        case 0: return "Create my plan"
        case 1: return "Continue"
        case 2: return "Set my rhythm"
        default: return "Start my journey"
        }
    }

    private var backSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 40)
            .onEnded { value in
                guard currentStep > 0,
                      value.translation.width > 85,
                      abs(value.translation.height) < 90 else { return }
                withAnimation(.spring(response: 0.44, dampingFraction: 0.86)) {
                    currentStep -= 1
                }
            }
    }

    private var artFloatAnimation: Animation? {
        guard !reduceMotion else { return nil }
        return .easeInOut(duration: 3.4).repeatForever(autoreverses: true)
    }

    private func startArtAnimation() {
        artIsAlive = false
        guard !reduceMotion else {
            artIsAlive = true
            return
        }
        DispatchQueue.main.async {
            artIsAlive = true
        }
    }

    private func advance() {
        if currentStep == totalSteps - 1 {
            if notificationsToggle {
                let storedHour = UserDefaults.standard.integer(forKey: "notificationHour")
                NotificationService.shared.rescheduleAll(hour: storedHour == 0 ? 9 : storedHour, enabled: true)
            }
            viewModel.complete()
            return
        }

        withAnimation(.spring(response: 0.44, dampingFraction: 0.86)) {
            currentStep += 1
        }
    }

    private func updateNotificationPreference(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        if enabled {
            NotificationService.shared.requestAuthorization()
        } else {
            NotificationService.shared.cancelAll()
        }
    }
}

private enum LotusPalette {
    static let ink = Color(red: 0.045, green: 0.085, blue: 0.235)
    static let muted = Color(red: 0.37, green: 0.42, blue: 0.58)
    static let dot = Color(red: 0.86, green: 0.88, blue: 0.93)
    static let aqua = Color(red: 0.16, green: 0.78, blue: 0.98)
    static let cobalt = Color(red: 0.16, green: 0.35, blue: 0.96)
    static let violet = Color(red: 0.49, green: 0.30, blue: 0.98)
    static let coral = Color(red: 1.00, green: 0.38, blue: 0.65)

    static let buttonGradient = LinearGradient(
        colors: [aqua, cobalt, violet, coral],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let selectedTokenGradient = LinearGradient(
        colors: [aqua, cobalt, violet],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let inactiveTokenGradient = LinearGradient(
        colors: [Color.white.opacity(0.96), aqua.opacity(0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel())
}
