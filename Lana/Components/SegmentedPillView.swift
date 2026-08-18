import SwiftUI

struct SegmentedPillView: View {
    @Binding var selected: LessonTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach(LessonTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selected = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundStyle(selected == tab ? .black : DarkDS.muted)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(selected == tab ? DarkDS.lime : DarkDS.card2)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
