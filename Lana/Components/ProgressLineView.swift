import SwiftUI

struct ProgressLineView: View {
    let value: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.2))
                Capsule()
                    .fill(Color.black.opacity(0.75))
                    .frame(width: width * CGFloat(min(max(value, 0), 1)))
            }
        }
        .frame(height: 6)
    }
}
