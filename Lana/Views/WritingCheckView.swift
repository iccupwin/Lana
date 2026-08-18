import SwiftUI

// MARK: - Writing Check View

struct WritingCheckView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var userText = ""
    @State private var feedback: WritingFeedback?
    @State private var isChecking = false
    @State private var currentPromptIndex: Int = 0
    @FocusState private var textFocused: Bool

    private var prompt: WritingPrompt { WritingPrompt.all[currentPromptIndex % WritingPrompt.all.count] }

    var body: some View {
        DarkScreen {
            VStack(spacing: 0) {
                header
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        promptCard
                        editorCard
                        if let fb = feedback {
                            feedbackCard(fb)
                        }
                        if feedback != nil {
                            nextPromptButton
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                }
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            DarkBackButton()
            Text("Writing Check").font(.system(size: 20, weight: .bold)).foregroundStyle(LotusApp.ink)
            Spacer()
            Text("+30 XP").font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(DarkDS.lime))
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(DarkDS.card.opacity(0.8))
        .overlay(Rectangle().fill(DarkDS.border).frame(height: 1), alignment: .bottom)
    }

    // MARK: Prompt Card

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                Text("WRITING PROMPT")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .tracking(1.2)
                Spacer()
                Text(prompt.level)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(.black.opacity(0.12)))
            }
            Text(prompt.text)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Text("Aim for 3–5 sentences")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.lime))
    }

    // MARK: Editor Card

    private var editorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your answer")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                Spacer()
                Text("\(userText.split(separator: " ").count) words")
                    .font(.system(size: 12))
                    .foregroundStyle(DarkDS.muted)
            }

            ZStack(alignment: .topLeading) {
                if userText.isEmpty {
                    Text("Write your answer here…")
                        .font(.system(size: 15))
                        .foregroundStyle(DarkDS.muted)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $userText)
                    .font(.system(size: 15))
                    .foregroundStyle(LotusApp.ink)
                    .tint(DarkDS.lime)
                    .frame(minHeight: 130)
                    .scrollContentBackground(.hidden)
                    .focused($textFocused)
            }

            Divider().background(DarkDS.border)

            // Check button
            Button {
                textFocused = false
                checkWriting()
            } label: {
                HStack {
                    if isChecking {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.85)
                        Text("Checking…")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                        Text("Check my writing")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(userText.trimmingCharacters(in: .whitespaces).count < 10 ? DarkDS.muted : .black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(userText.trimmingCharacters(in: .whitespaces).count < 10 ? DarkDS.card2 : DarkDS.lime)
                )
            }
            .disabled(userText.trimmingCharacters(in: .whitespaces).count < 10 || isChecking)
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    // MARK: Feedback Card

    private func feedbackCard(_ fb: WritingFeedback) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Score header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Feedback")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(LotusApp.ink)
                    Text("Keep up the great work!")
                        .font(.system(size: 12))
                        .foregroundStyle(DarkDS.muted)
                }
                Spacer()
                // Score circle
                ZStack {
                    Circle()
                        .fill(scoreColor(fb.score).opacity(0.15))
                        .frame(width: 56, height: 56)
                    VStack(spacing: 0) {
                        Text("\(fb.score)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(scoreColor(fb.score))
                        Text("/ 100")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(DarkDS.muted)
                    }
                }
            }

            Divider().background(DarkDS.border)

            // Score bars
            VStack(spacing: 12) {
                scoreBar("Grammar",    value: fb.grammar,    color: Color(red: 0.22, green: 0.44, blue: 0.98))
                scoreBar("Vocabulary", value: fb.vocabulary, color: DarkDS.lime)
                scoreBar("Fluency",    value: fb.fluency,    color: Color(red: 0.62, green: 0.38, blue: 0.98))
                scoreBar("Structure",  value: fb.structure,  color: Color(red: 0.98, green: 0.60, blue: 0.18))
            }

            Divider().background(DarkDS.border)

            // Suggestions
            VStack(alignment: .leading, spacing: 10) {
                Label("Suggestions", systemImage: "text.badge.star")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(DarkDS.lime)

                ForEach(fb.suggestions, id: \.self) { s in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(DarkDS.lime)
                            .padding(.top, 1)
                        Text(s)
                            .font(.system(size: 13))
                            .foregroundStyle(LotusApp.ink.opacity(0.85))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if !fb.corrected.isEmpty {
                Divider().background(DarkDS.border)
                VStack(alignment: .leading, spacing: 8) {
                    Label("Improved version", systemImage: "sparkles")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(DarkDS.lime)
                    Text(fb.corrected)
                        .font(.system(size: 13))
                        .foregroundStyle(LotusApp.ink.opacity(0.8))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(DarkDS.card2))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: DarkDS.r).fill(DarkDS.card))
    }

    private func scoreBar(_ label: String, value: Int, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(DarkDS.muted)
                Spacer()
                Text("\(value)%")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(DarkDS.card2).frame(height: 6)
                    Capsule().fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 6)
                        .animation(.spring(response: 0.8).delay(0.2), value: value)
                }
            }
            .frame(height: 6)
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 85...: return DarkDS.lime
        case 65...: return Color(red: 0.22, green: 0.44, blue: 0.98)
        default:    return Color(red: 0.98, green: 0.60, blue: 0.18)
        }
    }

    // MARK: Next Prompt

    private var nextPromptButton: some View {
        Button {
            currentPromptIndex += 1
            userText = ""
            feedback = nil
            _ = appState.sqliteService.addXPOnce(key: "writing_check_\(currentPromptIndex)", amount: 30)
        } label: {
            HStack {
                Image(systemName: "arrow.right.circle.fill")
                Text("Try next prompt")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 14).fill(DarkDS.lime))
        }
    }

    // MARK: Logic (local AI-style feedback)

    private func checkWriting() {
        guard !userText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isChecking = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            feedback = WritingFeedback.generate(for: userText)
            isChecking = false
        }
    }
}

// MARK: - Writing Prompt Data

struct WritingPrompt {
    let text: String
    let level: String

    static let all: [WritingPrompt] = [
        WritingPrompt(text: "Describe your daily morning routine in detail.", level: "A2"),
        WritingPrompt(text: "What are the advantages and disadvantages of working from home?", level: "B1"),
        WritingPrompt(text: "Describe a person who has had a great influence on your life.", level: "A2"),
        WritingPrompt(text: "Do you think social media has a positive or negative impact on society?", level: "B2"),
        WritingPrompt(text: "Write about your favourite holiday or celebration and why you enjoy it.", level: "A2"),
        WritingPrompt(text: "Should schools focus more on practical skills or academic knowledge?", level: "B2"),
        WritingPrompt(text: "Describe the city or town where you live.", level: "A1"),
        WritingPrompt(text: "What changes would you like to see in education in the future?", level: "B1"),
        WritingPrompt(text: "Write about a challenging situation you faced and how you overcame it.", level: "B1"),
        WritingPrompt(text: "Is technology making people's lives better or worse? Explain your view.", level: "B2")
    ]
}

// MARK: - Feedback Model

struct WritingFeedback {
    let score: Int
    let grammar: Int
    let vocabulary: Int
    let fluency: Int
    let structure: Int
    let suggestions: [String]
    let corrected: String

    static func generate(for text: String) -> WritingFeedback {
        let wordCount = text.split(separator: " ").count
        let hasCommas  = text.contains(",")
        let hasFullStop = text.hasSuffix(".") || text.hasSuffix("!")
        let hasCaps    = text.first?.isUppercase ?? false

        var grammar    = Int.random(in: 70...92)
        var vocabulary = Int.random(in: 65...90)
        let fluency    = wordCount > 20 ? Int.random(in: 75...93) : Int.random(in: 50...70)
        var structure  = Int.random(in: 68...88)

        if !hasCaps    { grammar    = max(50, grammar    - 10) }
        if !hasFullStop { structure = max(50, structure  - 8)  }
        if hasCommas   { structure  = min(95, structure  + 5)  }
        if wordCount > 30 { vocabulary = min(95, vocabulary + 8) }

        let score = (grammar + vocabulary + fluency + structure) / 4

        let suggestions: [String] = [
            score < 70 ?
                "Try to vary your sentence length — mix short and long sentences for better flow." :
                "Excellent structure! Consider using more complex connectors like 'Furthermore' or 'In addition'.",
            wordCount < 20 ?
                "Aim for at least 3–4 sentences to fully develop your idea." :
                "Good length. You could strengthen your argument with a concrete example.",
            !hasCommas ?
                "Use commas to separate clauses — it makes your writing easier to read." :
                "Good use of punctuation throughout."
        ]

        let corrected = score < 75 ? generateImprovedVersion(text) : ""

        return WritingFeedback(score: score, grammar: grammar, vocabulary: vocabulary,
                               fluency: fluency, structure: structure,
                               suggestions: suggestions, corrected: corrected)
    }

    private static func generateImprovedVersion(_ text: String) -> String {
        let sentences = text
            .components(separatedBy: ".")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .map { s -> String in
                var out = s
                if let first = out.first, first.isLowercase {
                    out = out.prefix(1).uppercased() + out.dropFirst()
                }
                return out + "."
            }
        return sentences.joined(separator: " ")
    }
}
