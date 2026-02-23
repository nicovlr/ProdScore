import Foundation

struct ScoreManager {
    static let suiteName = "group.com.prodscore.app"

    static var score: Int {
        get { UserDefaults(suiteName: suiteName)?.integer(forKey: "score") ?? 0 }
        set { UserDefaults(suiteName: suiteName)?.set(newValue, forKey: "score") }
    }

    static var message: String {
        get { UserDefaults(suiteName: suiteName)?.string(forKey: "message") ?? "" }
        set { UserDefaults(suiteName: suiteName)?.set(newValue, forKey: "message") }
    }
}
