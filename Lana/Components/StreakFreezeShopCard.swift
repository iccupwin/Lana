import SwiftUI

/// Card shown in profile/shop that lets the user buy a Streak Freeze for 200 XP.
struct StreakFreezeShopCard: View {
    @EnvironmentObject private var appState: AppState
    @State private var hasFreeze: Bool = false
    @State private var showConfirm: Bool = false
    @State private var showSuccess: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.22, green: 0.44, blue: 0.98).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: "shield.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            }

            // Labels
            VStack(alignment: .leading, spacing: 3) {
                Text("Streak Freeze")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.white)
                Text("Protect your streak for 1 day")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(DarkDS.muted)
            }

            Spacer()

            // Action area
            if hasFreeze {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                    Text("Active")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.43))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.14))
                        .overlay(Capsule().strokeBorder(Color(red: 0.20, green: 0.78, blue: 0.43).opacity(0.35), lineWidth: 1))
                )
            } else {
                Button {
                    showConfirm = true
                } label: {
                    Text("200 XP")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(DarkDS.lime))
                }
                .buttonStyle(.plain)
                .disabled(appState.totalXP < 200)
                .opacity(appState.totalXP < 200 ? 0.45 : 1.0)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(DarkDS.card)
                .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(DarkDS.border, lineWidth: 1))
        )
        .onAppear { hasFreeze = appState.sqliteService.hasStreakFreeze() }
        .alert("Activate Streak Freeze?", isPresented: $showConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Buy for 200 XP") {
                purchase()
            }
        } message: {
            Text("Spend 200 XP to protect your streak for the next missed day.")
        }
        .overlay(alignment: .top) {
            if showSuccess {
                successToast
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
    }

    // MARK: - Success Toast

    private var successToast: some View {
        HStack(spacing: 8) {
            Image(systemName: "shield.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.22, green: 0.44, blue: 0.98))
            Text("Streak Freeze activated!")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(DarkDS.card2)
                .overlay(Capsule().strokeBorder(DarkDS.border, lineWidth: 1))
        )
        .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        .padding(.top, -44)
    }

    // MARK: - Purchase Logic

    private func purchase() {
        let success = appState.sqliteService.activateStreakFreeze()
        guard success else { return }
        // Reflect the XP deduction in AppState
        appState.refreshAll()
        hasFreeze = true
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            showSuccess = true
        }
        HapticService.shared.notify(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                showSuccess = false
            }
        }
    }
}
