import SwiftUI

/// Height of the floating LotusTabBar zone (bar + its vertical padding).
/// Screens pushed inside a nested NavigationStack don't inherit the TabView's
/// safeAreaInset, so bottom-pinned controls on those screens must add this
/// clearance themselves to stay above the bar.
enum FloatingTabBarMetrics {
    static let clearance: CGFloat = 74
}

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab = 0
    @State private var practicePath = NavigationPath()
    @State private var resetKeys = Array(repeating: 0, count: 5)

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: HomeViewModel())
                .toolbar(.hidden, for: .tabBar)
                .environmentObject(appState)
                .id(resetKeys[0])
                .tag(0)

            NavigationStack(path: $practicePath) {
                PracticeHubView()
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(appState)
            .tag(1)

            NavigationStack {
                SavedWordsView(viewModel: SavedWordsViewModel(sqliteService: appState.sqliteService))
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(appState)
            .id(resetKeys[2])
            .tag(2)

            NavigationStack {
                ProgressScreen(viewModel: ProgressViewModel(sqliteService: appState.sqliteService))
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(appState)
            .id(resetKeys[3])
            .tag(3)

            NavigationStack {
                ProfileView(viewModel: ProfileViewModel(sqliteService: appState.sqliteService))
                    .toolbar(.hidden, for: .tabBar)
            }
            .environmentObject(appState)
            .id(resetKeys[4])
            .tag(4)
        }
        .tint(LotusApp.cobalt)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            LotusTabBar(selectedTab: $selectedTab, onTapSameTab: resetTab)
                .padding(.horizontal, 14)
                .padding(.top, 7)
                .padding(.bottom, 7)
        }
        .overlay(alignment: .top) {
            if let message = appState.xpToastMessage {
                XPToastView(message: message)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(999)
            }
        }
        .overlay(alignment: .bottom) {
            if let toast = appState.achievementToast {
                AchievementBannerView(icon: toast.icon, title: toast.title)
                    .padding(.bottom, 102)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(998)
            }
        }
        .overlay {
            if let info = appState.pendingLevelUp {
                LevelUpCelebrationView(levelInfo: info) {
                    appState.pendingLevelUp = nil
                }
                .zIndex(1000)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: selectedTab)
        .animation(.easeInOut(duration: 0.2), value: appState.pendingLevelUp?.level)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: appState.xpToastMessage)
        .animation(.spring(response: 0.45, dampingFraction: 0.75), value: appState.achievementToast?.title)
    }

    private func resetTab(_ index: Int) {
        if index == 1 {
            practicePath = NavigationPath()
        } else {
            resetKeys[index] += 1
        }
    }
}

struct LotusTabBar: View {
    @Binding var selectedTab: Int
    let onTapSameTab: (Int) -> Void

    @Namespace private var activeTab

    private let tabs: [(icon: String, label: String)] = [
        ("house.fill", "Home"),
        ("circle.grid.cross.fill", "Practice"),
        ("bookmark.fill", "Saved"),
        ("chart.bar.fill", "Progress"),
        ("person.crop.circle.fill", "Profile")
    ]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(tabs.indices, id: \.self) { index in
                tabButton(index)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25, style: .continuous))
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(Color.white.opacity(0.78))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .stroke(Color.white.opacity(0.98), lineWidth: 1)
        }
        .shadow(color: LotusApp.ink.opacity(0.10), radius: 20, y: 8)
        .accessibilityElement(children: .contain)
    }

    private func tabButton(_ index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            HapticService.shared.selection()
            withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                if isSelected {
                    onTapSameTab(index)
                } else {
                    selectedTab = index
                }
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(LotusApp.softAurora)
                            .matchedGeometryEffect(id: "activeTab", in: activeTab)
                            .frame(width: 42, height: 26)
                    }

                    Image(systemName: tabs[index].icon)
                        .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(isSelected ? AnyShapeStyle(LotusApp.aurora) : AnyShapeStyle(LotusApp.muted.opacity(0.64)))
                        .symbolEffect(.bounce, value: isSelected)
                }
                .frame(height: 27)

                Text(tabs[index].label)
                    .font(.system(size: 9, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? LotusApp.cobalt : LotusApp.muted.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(tabs[index].label)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
