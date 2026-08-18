import Foundation
import Combine

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage]
    @Published var inputText: String = ""

    init() {
        messages = [
            ChatMessage(id: "m1", text: "Hi! I'm glad you care about your health.", isUser: false),
            ChatMessage(id: "m2", text: "What do you think is important for staying healthy?", isUser: false),
            ChatMessage(id: "m3", text: "I think exercising, eating right, and going to the doctor regularly.", isUser: true),
            ChatMessage(id: "m4", text: "By the way, do you vaccinate?", isUser: false),
            ChatMessage(id: "m5", text: "Of course! Vaccines stop diseases from spreading and keep people healthy.", isUser: true)
        ]
    }

    func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        messages.append(ChatMessage(id: UUID().uuidString, text: trimmed, isUser: true))
        inputText = ""
    }
}
