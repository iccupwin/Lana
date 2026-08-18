import SwiftUI

// MARK: - Scenario List

struct DialoguePracticeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var activeScenario: DialogueScenario? = nil

    var body: some View {
        DarkScreen {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    pageHeader
                    infoCard
                    scenariosGrid
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 110)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(item: $activeScenario) { scenario in
            DialogueSessionView(scenario: scenario)
                .environmentObject(appState)
        }
    }

    private var pageHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dialogue")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("Real-life conversations")
                    .font(.system(size: 14))
                    .foregroundStyle(DarkDS.muted)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "message.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            }
        }
        .padding(.top, 16)
    }

    private var infoCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            VStack(alignment: .leading, spacing: 3) {
                Text("How it works")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("Read the native speaker's lines, then choose the best response. Pick all 4 correctly to earn full XP.")
                    .font(.system(size: 11))
                    .foregroundStyle(DarkDS.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.10))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.3), lineWidth: 1))
        )
    }

    private var scenariosGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(DialoguePracticeViewModel.allScenarios) { scenario in
                Button { activeScenario = scenario } label: {
                    scenarioCard(scenario)
                }
                .buttonStyle(PressScaleStyle())
            }
        }
    }

    private func scenarioCard(_ scenario: DialogueScenario) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: scenario.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            }
            VStack(spacing: 4) {
                Text(scenario.title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                Text(scenario.situation)
                    .font(.system(size: 10))
                    .foregroundStyle(DarkDS.muted)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            Text("+20 XP")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.lime)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().fill(DarkDS.lime.opacity(0.12)))
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(DarkDS.card))
    }
}

// MARK: - Dialogue Session

struct DialogueSessionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: DialoguePracticeViewModel

    init(scenario: DialogueScenario) {
        _vm = StateObject(wrappedValue: DialoguePracticeViewModel(scenario: scenario))
    }

    var body: some View {
        ZStack {
            DarkDS.bg.ignoresSafeArea()

            if vm.isFinished {
                finishedScreen
            } else {
                VStack(spacing: 0) {
                    topBar
                    chatArea
                    if vm.isChoosingOption, let opts = vm.currentOptionSet {
                        optionArea(opts)
                    } else if vm.isAnswered {
                        continueButton
                    }
                }
            }
        }
        .onChange(of: vm.isFinished) { finished in
            if finished {
                appState.triggerAchievement("first_sentence_builder")
            }
        }
    }

    // MARK: Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                ZStack {
                    Circle().fill(DarkDS.card2).frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(LotusApp.ink)
                }
            }
            .buttonStyle(PressScaleStyle())

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.scenario.title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text(vm.scenario.situation)
                    .font(.system(size: 11))
                    .foregroundStyle(DarkDS.muted)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
                Text("\(vm.score)/\(vm.totalUserTurns)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(Capsule().fill(Color(red: 0.98, green: 0.79, blue: 0.20).opacity(0.15)))
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(DarkDS.card.ignoresSafeArea(edges: .top))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Chat Area

    private var chatArea: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(vm.visibleTurns) { turn in
                        chatBubble(turn).id(turn.id)
                    }
                    if vm.isChoosingOption {
                        nativeTypingIndicator
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.bottom, 20)
            }
            .onChange(of: vm.visibleTurns.count) { _ in
                if let last = vm.visibleTurns.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func chatBubble(_ turn: DialoguePracticeViewModel.RenderedTurn) -> some View {
        if turn.speaker == .native {
            HStack(alignment: .bottom, spacing: 8) {
                ZStack {
                    Circle().fill(DarkDS.card2).frame(width: 30, height: 30)
                    Image(systemName: "person.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DarkDS.muted)
                }
                Text(turn.text)
                    .font(.system(size: 14))
                    .foregroundStyle(LotusApp.ink)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(DarkDS.card))
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                Spacer()
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .leading)),
                removal: .opacity
            ))
        } else {
            HStack(alignment: .bottom, spacing: 8) {
                Spacer()
                Text(turn.text)
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(turn.wasCorrect == true
                                  ? DarkDS.lime
                                  : (turn.wasCorrect == false
                                     ? Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.8)
                                     : Color(red: 0.22, green: 0.44, blue: 0.98)))
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                if let correct = turn.wasCorrect {
                    Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(correct
                            ? Color(red: 0.20, green: 0.78, blue: 0.43)
                            : Color(red: 0.98, green: 0.30, blue: 0.30))
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .move(edge: .trailing)),
                removal: .opacity
            ))
        }
    }

    private var nativeTypingIndicator: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle().fill(DarkDS.card2).frame(width: 30, height: 30)
                Image(systemName: "person.fill").font(.system(size: 13)).foregroundStyle(DarkDS.muted)
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { _ in
                    Circle().fill(DarkDS.muted).frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.card))
            Spacer()
        }
    }

    // MARK: Option Buttons

    private func optionArea(_ opts: DialoguePracticeViewModel.OptionSet) -> some View {
        VStack(spacing: 8) {
            Divider().background(DarkDS.border)
            Text("Choose your response:")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            VStack(spacing: 8) {
                ForEach(opts.options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            vm.chooseOption(option)
                        }
                    } label: {
                        Text(option)
                            .font(.system(size: 14))
                            .foregroundStyle(LotusApp.ink)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14).padding(.vertical, 12)
                            .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.card))
                            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(DarkDS.border, lineWidth: 1))
                    }
                    .buttonStyle(PressScaleStyle())
                    .padding(.horizontal, 16)
                    .disabled(vm.isAnswered)
                }
            }
            .padding(.bottom, 20)
        }
        .background(DarkDS.bg)
    }

    // MARK: Continue Button

    private var continueButton: some View {
        VStack(spacing: 0) {
            Divider().background(DarkDS.border)
            HStack(spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: vm.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(vm.lastAnswerCorrect
                            ? Color(red: 0.20, green: 0.78, blue: 0.43)
                            : Color(red: 0.98, green: 0.30, blue: 0.30))
                    Text(vm.lastAnswerCorrect ? "Correct!" : "Wrong")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(vm.lastAnswerCorrect
                            ? Color(red: 0.20, green: 0.78, blue: 0.43)
                            : Color(red: 0.98, green: 0.30, blue: 0.30))
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        vm.continueDialogue()
                    }
                } label: {
                    Text("Continue")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.lime))
                }
                .buttonStyle(PressScaleStyle())
            }
            .padding(.horizontal, 20).padding(.vertical, 14)
        }
        .background(DarkDS.bg)
    }

    // MARK: Finished Screen

    private var finishedScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle().fill(DarkDS.lime.opacity(0.10)).frame(width: 160, height: 160)
                Circle().fill(DarkDS.lime.opacity(0.20)).frame(width: 110, height: 110)
                Image(systemName: vm.scenario.icon)
                    .font(.system(size: 52, weight: .semibold))
                    .foregroundStyle(DarkDS.lime)
            }
            VStack(spacing: 8) {
                Text("SCENARIO COMPLETE!")
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(DarkDS.lime)
                    .tracking(2)
                Text(vm.scenario.title)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
                Text("\(vm.score)/\(vm.totalUserTurns) correct")
                    .font(.system(size: 15))
                    .foregroundStyle(DarkDS.muted)
            }
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(DarkDS.lime)
                Text("+\(vm.score * 5) XP earned")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime.opacity(0.12)))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(DarkDS.lime.opacity(0.3), lineWidth: 1))

            Button { dismiss() } label: {
                Text("Done")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(RoundedRectangle(cornerRadius: 18).fill(DarkDS.lime))
            }
            .buttonStyle(PressScaleStyle())
            .padding(.horizontal, 32)
            Spacer()
        }
    }
}
