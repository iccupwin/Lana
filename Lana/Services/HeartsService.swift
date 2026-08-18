import Foundation
import Combine

final class HeartsService: ObservableObject {
    static let shared = HeartsService()

    static let max = 5
    private let regenInterval: TimeInterval = 1800  // 30 min per heart

    @Published var hearts: Int = HeartsService.max
    @Published var regenLabel: String = ""          // "14:22" countdown, empty when full

    private var displayTimer: Timer?

    private init() {
        hearts = storedHearts
        processRegen()
        startDisplayTimer()
    }

    // MARK: - Public API

    /// Deduct one heart on a wrong answer. No-op when already empty.
    func useHeart() {
        guard hearts > 0 else { return }
        let wasMax = (hearts == HeartsService.max)
        hearts -= 1
        storedHearts = hearts
        if wasMax {
            // Start the regen clock from this moment
            regenStartDate = Date()
        }
    }

    var isEmpty: Bool { hearts == 0 }
    var isFull: Bool  { hearts >= HeartsService.max }

    // MARK: - Regen

    private func processRegen() {
        guard hearts < HeartsService.max, let start = regenStartDate else {
            if hearts < HeartsService.max { hearts = HeartsService.max }
            return
        }
        let elapsed  = Date().timeIntervalSince(start)
        let regened  = Int(elapsed / regenInterval)
        guard regened > 0 else { return }
        hearts = min(HeartsService.max, hearts + regened)
        storedHearts = hearts
        // Advance regen start by the intervals already consumed
        regenStartDate = start.addingTimeInterval(Double(regened) * regenInterval)
        if hearts == HeartsService.max { regenStartDate = nil }
    }

    private func updateRegenLabel() {
        processRegen()
        guard hearts < HeartsService.max, let start = regenStartDate else {
            regenLabel = ""
            return
        }
        let elapsed   = Date().timeIntervalSince(start)
        let remaining = regenInterval - elapsed.truncatingRemainder(dividingBy: regenInterval)
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        regenLabel = String(format: "%d:%02d", m, s)
    }

    private func startDisplayTimer() {
        displayTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async { self?.updateRegenLabel() }
        }
    }

    // MARK: - Persistence (UserDefaults)

    private var storedHearts: Int {
        get {
            let v = UserDefaults.standard.integer(forKey: "lana_hearts_count")
            return v == 0 ? HeartsService.max : v
        }
        set { UserDefaults.standard.set(newValue, forKey: "lana_hearts_count") }
    }

    private var regenStartDate: Date? {
        get { UserDefaults.standard.object(forKey: "lana_hearts_regen_start") as? Date }
        set { UserDefaults.standard.set(newValue, forKey: "lana_hearts_regen_start") }
    }
}
