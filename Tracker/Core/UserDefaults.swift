import Foundation

final class UserDefaultsService {

    static let shared = UserDefaultsService()
    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    private enum Key {
        static let onboardingCompleted = "onboardingCompleted"
    }

    var isOnboardingCompleted: Bool {
        get {
            defaults.bool(forKey: Key.onboardingCompleted)
        }
        set {
            defaults.set(newValue, forKey: Key.onboardingCompleted)
        }
    }
}
