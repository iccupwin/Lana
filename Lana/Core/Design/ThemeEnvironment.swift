import SwiftUI

struct ThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .light
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

struct ThemeModifier: ViewModifier {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var theme: AppTheme {
        isDarkMode ? .dark : .light
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.theme, theme)
            .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

extension View {
    func withAppTheme() -> some View {
        modifier(ThemeModifier())
    }
}

struct ThemeToggleButton: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                isDarkMode.toggle()
            }
        } label: {
            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isDarkMode ? Color.yellow : Color.blue)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(isDarkMode ? Color.white.opacity(0.1) : Color.blue.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}
