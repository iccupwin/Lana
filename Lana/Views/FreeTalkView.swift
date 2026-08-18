import SwiftUI
import Combine

// MARK: - AI Free Talk View (dark theme)

struct FreeTalkView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: AIConversationViewModel

    let topic: String

    init(topic: String, prompt: String) {
        self.topic = topic
        _vm = StateObject(wrappedValue: AIConversationViewModel(opening: prompt))
    }

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                chatHeader
                messagesScrollView
                inputBar
            }
        }
        .onAppear { appState.sqliteService.addXPOnce(key: "freetalk_\(topic)", amount: 15) }
    }

    // MARK: Header

    private var chatHeader: some View {
        HStack(spacing: 14) {
            DarkBackButton()

            ZStack {
                Circle()
                    .fill(DarkDS.lime.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "cpu.fill")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(DarkDS.lime)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("AI Coach").font(.system(size: 15, weight: .bold)).foregroundStyle(LotusApp.ink)
                Text(topic).font(.system(size: 12)).foregroundStyle(DarkDS.muted)
            }

            Spacer()

            // Online indicator
            HStack(spacing: 5) {
                Circle().fill(DarkDS.lime).frame(width: 7, height: 7)
                Text("Online").font(.system(size: 11, weight: .medium)).foregroundStyle(DarkDS.muted)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Messages

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(vm.messages) { msg in
                        messageBubble(msg)
                            .id(msg.id)
                    }
                    if vm.isTyping {
                        typingIndicator
                            .id("typing")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            }
            .onChange(of: vm.isTyping) { _ in
                withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
            }
        }
    }

    private func messageBubble(_ msg: AIMessage) -> some View {
        HStack(alignment: .bottom, spacing: 10) {
            if msg.isUser {
                Spacer(minLength: 44)
                Text(msg.text)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(DarkDS.lime, in: BubbleShape(isUser: true))
            } else {
                // AI avatar
                ZStack {
                    Circle().fill(DarkDS.card2).frame(width: 34, height: 34)
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(DarkDS.lime)
                }
                .alignmentGuide(.bottom) { d in d[.bottom] }

                Text(msg.text)
                    .font(.system(size: 15))
                    .foregroundStyle(LotusApp.ink)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(DarkDS.card, in: BubbleShape(isUser: false))
                Spacer(minLength: 44)
            }
        }
    }

    private var typingIndicator: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ZStack {
                Circle().fill(DarkDS.card2).frame(width: 34, height: 34)
                Image(systemName: "cpu.fill").font(.system(size: 13)).foregroundStyle(DarkDS.lime)
            }
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(DarkDS.muted)
                        .frame(width: 7, height: 7)
                        .scaleEffect(vm.typingPhase == i ? 1.3 : 0.8)
                        .animation(
                            .easeInOut(duration: 0.4)
                                .repeatForever()
                                .delay(Double(i) * 0.15),
                            value: vm.typingPhase
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(DarkDS.card, in: BubbleShape(isUser: false))
            Spacer(minLength: 44)
        }
    }

    // MARK: Input bar

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $vm.draft, axis: .vertical)
                .font(.system(size: 15))
                .foregroundStyle(LotusApp.ink)
                .tint(DarkDS.lime)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DarkDS.card, in: RoundedRectangle(cornerRadius: 22))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(DarkDS.border, lineWidth: 1)
                )

            Button {
                vm.send()
            } label: {
                ZStack {
                    Circle()
                        .fill(vm.draft.trimmingCharacters(in: .whitespaces).isEmpty
                              ? DarkDS.card : DarkDS.lime)
                        .frame(width: 46, height: 46)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(vm.draft.trimmingCharacters(in: .whitespaces).isEmpty
                                         ? DarkDS.muted : .black)
                }
            }
            .disabled(vm.draft.trimmingCharacters(in: .whitespaces).isEmpty || vm.isTyping)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .padding(.bottom, FloatingTabBarMetrics.clearance)
        .background(
            DarkDS.card.opacity(0.95)
                .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .top)
        )
    }
}

// MARK: - Bubble Shape

struct BubbleShape: Shape {
    var isUser: Bool
    func path(in rect: CGRect) -> Path {
        let r: CGFloat = 18
        let tail: CGFloat = 6
        var p = Path()
        if isUser {
            p.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width - tail, height: rect.height),
                             cornerSize: CGSize(width: r, height: r))
        } else {
            p.addRoundedRect(in: CGRect(x: tail, y: 0, width: rect.width - tail, height: rect.height),
                             cornerSize: CGSize(width: r, height: r))
        }
        return p
    }
}

// MARK: - AI Conversation ViewModel

struct AIMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

@MainActor
final class AIConversationViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var draft: String = ""
    @Published var isTyping = false
    @Published var typingPhase = 0

    private let opening: String
    private var typingTimer: Timer?

    private let replies: [[String]] = [
        ["Great point! Can you tell me more about that?",
         "That's interesting! I'd love to hear more details.",
         "Nice! How did that make you feel?"],
        ["I completely understand. What happened next?",
         "That makes sense. Have you experienced something similar before?",
         "Interesting perspective! What do you think about it now?"],
        ["Excellent! Your English is really improving.",
         "Well said! Try adding a specific example to make it even stronger.",
         "Good job! Can you rephrase that using the past perfect tense?"],
        ["Could you expand on that idea a bit more?",
         "Very good! Now try using a more formal way to express that.",
         "That's correct! Let me give you another question on the same topic."],
        ["Perfect grammar there! Keep it up.",
         "You're making great progress. One small tip: use 'however' instead of 'but' for a more formal tone.",
         "Nice! That's a great use of vocabulary. Can you use it in another sentence?"]
    ]

    private var replyIndex = 0

    init(opening: String) {
        self.opening = opening
        Task { await addOpening() }
    }

    private func addOpening() async {
        try? await Task.sleep(nanoseconds: 600_000_000)
        messages.append(AIMessage(text: opening, isUser: false))
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messages.append(AIMessage(text: text, isUser: true))
        draft = ""
        Task { await generateReply() }
    }

    private func generateReply() async {
        isTyping = true
        startTypingAnimation()
        let delay = UInt64.random(in: 1_200_000_000...2_400_000_000)
        try? await Task.sleep(nanoseconds: delay)
        isTyping = false
        stopTypingAnimation()
        let pool = replies[replyIndex % replies.count]
        let reply = pool[Int.random(in: 0..<pool.count)]
        replyIndex += 1
        messages.append(AIMessage(text: reply, isUser: false))
    }

    private func startTypingAnimation() {
        typingTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.typingPhase = ((self?.typingPhase ?? 0) + 1) % 3
            }
        }
    }

    private func stopTypingAnimation() {
        typingTimer?.invalidate()
        typingTimer = nil
    }
}
