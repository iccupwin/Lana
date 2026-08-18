import SwiftUI

enum AppRoute: Hashable {
    case home
    case practice
    case saved
    case progress
    case profile
    case quizMap
    case quiz(stageId: String)
    case grammar
    case listening
    case movies
    case stories
    case settings
    case search
    case league
    case wordOfDay
}

struct AppNavigationStyle {
    static let defaultAnimation = Animation.spring(response: 0.35, dampingFraction: 0.8)
    static let quickAnimation = Animation.easeInOut(duration: 0.2)
}

struct NavigationAnimator: ViewModifier {
    @State private var viewId = 0
    
    func body(content: Content) -> some View {
        content
            .id(viewId)
    }
    
    func reset() {
        viewId += 1
    }
}

extension View {
    func withNavigationAnimation() -> some View {
        modifier(NavigationAnimator())
    }
}

struct AnimatedNavigationLink<Destination: View, Label: View>: View {
    let destination: Destination
    let label: () -> Label
    var animation: Animation = AppNavigationStyle.defaultAnimation
    
    init(
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.destination = destination()
        self.label = label
    }
    
    var body: some View {
        NavigationLink {
            destination
        } label: {
            label()
        }
    }
}


