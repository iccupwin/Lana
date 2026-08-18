import SwiftUI

struct CustomWordInputView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var word = ""
    @State private var translation = ""
    @State private var saved = false

    let onSave: () -> Void

    var body: some View {
        DarkScreen {
            VStack(spacing: 24) {
                header

                VStack(spacing: 16) {
                    inputField(title: "English Word", placeholder: "e.g. serendipity", text: $word)
                    inputField(title: "Translation", placeholder: "e.g. счастливое стечение обстоятельств", text: $translation)
                }

                saveButton

                Spacer()
            }
            .padding(20)
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LotusApp.ink)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(DarkDS.card))
            }
            Spacer()
            Text("Add Word")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Color.clear.frame(width: 34)
        }
        .padding(.top, 20)
    }

    private func inputField(title: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
            TextField(placeholder, text: text)
                .font(.system(size: 17, design: .rounded))
                .foregroundStyle(LotusApp.ink)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DarkDS.card)
                )
        }
    }

    private var saveButton: some View {
        let canSave = !word.trimmingCharacters(in: .whitespaces).isEmpty &&
                      !translation.trimmingCharacters(in: .whitespaces).isEmpty
        return Button {
            guard canSave else { return }
            appState.sqliteService.saveCustomWord(
                word: word.trimmingCharacters(in: .whitespaces),
                translation: translation.trimmingCharacters(in: .whitespaces)
            )
            appState.awardXP(5)
            onSave()
            dismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("Save Word")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(canSave ? .black : DarkDS.muted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(canSave ? DarkDS.lime : DarkDS.card2.opacity(0.5))
            )
        }
        .buttonStyle(PressScaleStyle())
        .disabled(!canSave)
    }
}
