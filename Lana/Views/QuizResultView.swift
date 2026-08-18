import SwiftUI

struct QuizResultView: View {
    let correctCount: Int
    let totalCount: Int
    let questionResults: [Bool]
    let onRestart: () -> Void

    private var percentage: Int {
        totalCount > 0 ? Int(Double(correctCount) / Double(totalCount) * 100) : 0
    }
    private var incorrectCount: Int { totalCount - correctCount }

    var body: some View {
        VStack(spacing: 20) {

            Image("LotusResultBloom")
                .resizable()
                .scaledToFit()
                .frame(height: 168)
                .accessibilityHidden(true)

            // Header row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.square.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
                    Text("Review result")
                        .font(.system(size: 24, weight: .regular, design: .serif))
                        .foregroundStyle(LotusApp.ink)
                }
                Spacer()
                Text("\(percentage)%")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(LotusApp.ink)
            }

            // Correct / Incorrect boxes
            HStack(spacing: 12) {
                resultBox(
                    icon: "checkmark.circle.fill",
                    label: "Correct",
                    count: correctCount,
                    color: Color(red: 0.20, green: 0.78, blue: 0.43),
                    bg: Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.12)
                )
                resultBox(
                    icon: "xmark.circle.fill",
                    label: "Incorrect",
                    count: incorrectCount,
                    color: Color(red: 0.98, green: 0.30, blue: 0.30),
                    bg: Color(red: 0.98, green: 0.30, blue: 0.30).opacity(0.12)
                )
            }

            // Questions grid
            if !questionResults.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Questions")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(DarkDS.muted)

                    let columns = Array(repeating: GridItem(.flexible()), count: 6)
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(questionResults.indices, id: \.self) { i in
                            questionCircle(number: i + 1, correct: questionResults[i])
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.84))
                        .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(DarkDS.border, lineWidth: 1))
                        .shadow(color: LotusApp.ink.opacity(0.045), radius: 14, y: 6)
                )
            }

            // Continue button
            Button(action: onRestart) {
                HStack {
                    Text("Continue")
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 18)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(RoundedRectangle(cornerRadius: 17).fill(LotusApp.aurora))
            }
            .buttonStyle(PressScaleStyle())
        }
    }

    private func resultBox(icon: String, label: String, count: Int, color: Color, bg: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Text("\(count)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(bg)
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(color.opacity(0.5), lineWidth: 1))
        )
    }

    private func questionCircle(number: Int, correct: Bool) -> some View {
        ZStack {
            Circle()
                .fill(correct
                      ? Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.15)
                      : Color.clear)
                .overlay(
                    Circle().strokeBorder(
                        correct
                            ? Color(red: 0.20, green: 0.78, blue: 0.43)
                            : Color(red: 0.98, green: 0.30, blue: 0.30),
                        lineWidth: 1.5
                    )
                )
                .frame(width: 40, height: 40)
            Text("\(number)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(correct
                    ? Color(red: 0.20, green: 0.78, blue: 0.43)
                    : Color(red: 0.98, green: 0.30, blue: 0.30))
        }
    }
}
