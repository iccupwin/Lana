import Foundation
import SwiftUI
import Combine

final class OnboardingViewModel: ObservableObject {
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @AppStorage("selectedCEFR") var selectedCEFR: String = "A1"
    @AppStorage("dailyMinuteGoal") var dailyMinuteGoal: Int = 10

    func complete() {
        hasOnboarded = true
    }
}
