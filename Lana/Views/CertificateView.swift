import SwiftUI

struct CertificateView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    private let userName: String

    init(userName: String) {
        self.userName = userName
    }

    var body: some View {
        DarkScreen {
            VStack(spacing: 24) {
                header
                certificateCard
                    .padding(.horizontal, 20)
                actionButtons
                    .padding(.horizontal, 20)
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(items: [img])
            }
        }
    }

    private var header: some View {
        HStack {
            DarkBackButton()
            Spacer()
            Text("Your Certificate")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(LotusApp.ink)
            Spacer()
            Color.clear.frame(width: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    @ViewBuilder
    private var certificateCard: some View {
        VStack(spacing: 20) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(Color(red: 0.98, green: 0.79, blue: 0.20))
            Text("Certificate of Achievement")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .tracking(1)
            Text(userName.isEmpty ? "English Learner" : userName)
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(LotusApp.ink)
            Rectangle()
                .fill(DarkDS.muted.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 20)
            Text("has successfully completed all lessons\nin the Lana English Learning Program")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted)
                .multilineTextAlignment(.center)
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("\(appState.totalXP)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text("Total XP")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text(appState.levelInfo.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text("Final Level")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
                .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    Text(CEFRLevel.level(for: appState.totalXP).rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(LotusApp.ink)
                    Text("CEFR")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(DarkDS.muted)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)
            Text(formattedDate)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(DarkDS.muted.opacity(0.6))
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(DarkDS.card)
        )
    }

    private var actionButtons: some View {
        Button {
            renderAndShare()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Certificate")
            }
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16).fill(DarkDS.lime))
        }
        .buttonStyle(PressScaleStyle())
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        return f.string(from: Date())
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content:
            certificateCard
                .frame(width: 340)
                .environment(\.colorScheme, .light)
        )
        renderer.scale = 3.0
        if let img = renderer.uiImage {
            shareImage = img
            showShareSheet = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uvc: UIActivityViewController, context: Context) {}
}
