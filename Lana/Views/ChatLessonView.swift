import SwiftUI

struct ChatLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ChatViewModel
    let title: String

    var body: some View {
        ZStack {
            DarkDS.bg.ignoresSafeArea()

            VStack(spacing: 12) {
                chatHeader

                VStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 38))
                        .foregroundStyle(Color(red: 0.62, green: 0.38, blue: 0.98))
                    Rectangle()
                        .fill(DarkDS.border)
                        .frame(height: 1)
                }
                .padding(.vertical, 8)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(viewModel.messages) { message in
                            ChatBubble(message: message)
                        }
                        TypingBubble()
                    }
                    .padding(.vertical, 8)
                }

                ChatInputBar(text: $viewModel.inputText) {
                    viewModel.send()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationBarHidden(true)
    }

    private var chatHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Circle()
                    .fill(DarkDS.card)
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(LotusApp.ink))
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(spacing: 2) {
                Text("Chat with AI bot")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(DarkDS.muted)
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LotusApp.ink)
            }

            Spacer()

            Circle()
                .fill(DarkDS.card)
                .frame(width: 32, height: 32)
                .overlay(Image(systemName: "face.smiling")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DarkDS.muted))
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }

            Text(message.text)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(message.isUser
                              ? Color(red: 0.62, green: 0.38, blue: 0.98).opacity(0.65)
                              : DarkDS.card)
                )
                .frame(maxWidth: 260, alignment: message.isUser ? .trailing : .leading)

            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct TypingBubble: View {
    var body: some View {
        HStack {
            Text("Typing...")
                .font(.system(size: 13, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))
            Spacer()
        }
    }
}

struct ChatInputBar: View {
    @Binding var text: String
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            TextField("Ask anything...", text: $text)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .tint(DarkDS.lime)
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.card))

            Button(action: onSend) {
                Circle()
                    .fill(DarkDS.lime)
                    .frame(width: 38, height: 38)
                    .overlay(
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(PressScaleStyle())
        }
    }
}

#Preview {
    NavigationStack {
        ChatLessonView(viewModel: ChatViewModel(), title: "Health Care")
    }
}
