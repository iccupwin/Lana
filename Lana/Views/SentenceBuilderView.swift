import SwiftUI

struct SentenceBuilderView: View {
    @StateObject private var vm = SentenceBuilderViewModel()
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        DarkScreen {
            if vm.isFinished {
                finishedView
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                VStack(spacing: 0) {
                    header
                    progressBar
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 18) {
                            if let puzzle = vm.current {
                                hintCard(puzzle)
                                answerArea
                                if vm.isAnswered {
                                    feedbackCard
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                    nextButton
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                } else {
                                    wordBankView
                                    submitButton
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 110)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.isAnswered)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.isFinished)
        .onChange(of: vm.isFinished) { finished in
            if finished {
                appState.triggerAchievement("first_sentence_builder")
                appState.checkAchievements()
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            DarkBackButton()

            Spacer()

            VStack(spacing: 2) {
                Text("SENTENCE BUILDER")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                    .tracking(1.5)
                Text("\(vm.currentIndex + 1) / \(vm.total)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }

            Spacer()

            Text("\(vm.score) ✓")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.4)))
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4).fill(DarkDS.card2).frame(height: 6)
                RoundedRectangle(cornerRadius: 4).fill(Color(red: 0.22, green: 0.44, blue: 0.98))
                    .frame(width: geo.size.width * vm.progress, height: 6)
                    .animation(.spring(response: 0.4), value: vm.progress)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Hint Card

    private func hintCard(_ puzzle: SentencePuzzle) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "flag.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(DarkDS.muted)
                Text("Translate into English")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }
            Text(puzzle.hint)
                .font(.system(size: 19, weight: .medium, design: .serif))
                .foregroundStyle(LotusApp.ink)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DarkDS.card)
        )
    }

    // MARK: - Answer Area

    private var answerArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your answer")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(answerBorderColor, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(answerBgColor)
                    )

                if vm.placed.isEmpty {
                    Text("Tap words below…")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted.opacity(0.6))
                        .padding(14)
                } else {
                    FlowLayout(spacing: 6) {
                        ForEach(vm.placed) { tile in
                            Button { vm.remove(tile) } label: {
                                Text(tile.word)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(LotusApp.ink)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 7)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.5))
                                    )
                            }
                            .buttonStyle(PressScaleStyle())
                            .disabled(vm.isAnswered)
                        }
                    }
                    .padding(10)
                }
            }
            .frame(minHeight: 80)
        }
    }

    private var answerBorderColor: Color {
        guard vm.isAnswered else { return DarkDS.border }
        return vm.isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.5) : Color.red.opacity(0.35)
    }

    private var answerBgColor: Color {
        guard vm.isAnswered else { return DarkDS.card.opacity(0.5) }
        return vm.isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.1) : Color.red.opacity(0.06)
    }

    // MARK: - Feedback Card

    private var feedbackCard: some View {
        HStack(spacing: 12) {
            Image(systemName: vm.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundStyle(vm.isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color.red)

            VStack(alignment: .leading, spacing: 3) {
                Text(vm.isCorrect ? "Correct!" : "Not quite…")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(vm.isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43) : Color.red)
                if !vm.isCorrect, let puzzle = vm.current {
                    Text(puzzle.answer.joined(separator: " "))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(vm.isCorrect ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15) : Color.red.opacity(0.08))
        )
    }

    // MARK: - Word Bank

    private var wordBankView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Word bank")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)

            FlowLayout(spacing: 8) {
                ForEach(vm.bank) { tile in
                    Button { vm.place(tile) } label: {
                        Text(tile.word)
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(LotusApp.ink)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DarkDS.card)
                            )
                    }
                    .buttonStyle(PressScaleStyle())
                }
            }
        }
    }

    // MARK: - Buttons

    private var submitButton: some View {
        Button { vm.submit() } label: {
            Text("Check Answer")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(vm.placed.isEmpty ? DarkDS.muted : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(vm.placed.isEmpty
                              ? DarkDS.card2
                              : DarkDS.lime)
                )
        }
        .buttonStyle(PressScaleStyle())
        .disabled(vm.placed.isEmpty)
    }

    private var nextButton: some View {
        Button { vm.next() } label: {
            HStack(spacing: 8) {
                Text(vm.currentIndex + 1 >= vm.total ? "See Results" : "Continue")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Image(systemName: vm.currentIndex + 1 >= vm.total ? "checkmark.circle.fill" : "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(DarkDS.lime)
            )
        }
        .buttonStyle(PressScaleStyle())
    }

    // MARK: - Finished View

    private var finishedView: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.2)).frame(width: 140, height: 140)
                Circle().fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.5)).frame(width: 100, height: 100)
                Image(systemName: vm.score >= 10 ? "trophy.fill" : vm.score >= 7 ? "star.fill" : vm.score >= 5 ? "hand.thumbsup.fill" : "figure.strengthtraining.traditional")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
            }

            VStack(spacing: 8) {
                Text("Well Done!")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(LotusApp.ink)
                Text("\(vm.score) out of \(vm.total) correct")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
            }

            HStack(spacing: 12) {
                finStat(label: "Correct", value: "\(vm.score)",       icon: "checkmark.circle.fill", color: Color(red: 0.20, green: 0.78, blue: 0.43))
                finStat(label: "XP",      value: "+\(vm.score * 5)",  icon: "bolt.fill",             color: Color(red: 0.98, green: 0.79, blue: 0.20))
                finStat(label: "Total",   value: "\(vm.total)",       icon: "list.number",           color: Color(red: 0.62, green: 0.38, blue: 0.98))
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
