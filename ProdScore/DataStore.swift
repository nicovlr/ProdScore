import Foundation
import WidgetKit

struct DataStore {
    static let suiteName = "group.com.prodscore.app"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Profile

    static var profile: UserProfile {
        get {
            guard let data = defaults?.data(forKey: "profile"),
                  let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
                return .default
            }
            return profile
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults?.set(data, forKey: "profile")
            }
        }
    }

    // MARK: - Products

    static var products: [Product] {
        get {
            guard let data = defaults?.data(forKey: "products"),
                  let products = try? JSONDecoder().decode([Product].self, from: data) else {
                return []
            }
            return products
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults?.set(data, forKey: "products")
            }
        }
    }

    // MARK: - Charges

    static var charges: [Charge] {
        get {
            guard let data = defaults?.data(forKey: "charges"),
                  let charges = try? JSONDecoder().decode([Charge].self, from: data) else {
                return []
            }
            return charges
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults?.set(data, forKey: "charges")
            }
        }
    }

    // MARK: - Selected Product

    static var selectedProductID: UUID? {
        get {
            guard let string = defaults?.string(forKey: "selectedProductID") else { return nil }
            return UUID(uuidString: string)
        }
        set {
            defaults?.set(newValue?.uuidString, forKey: "selectedProductID")
        }
    }

    // MARK: - Computed

    static var totalChargesPerMonth: Double {
        charges.reduce(0) { $0 + $1.amountPerMonth }
    }

    static var netPerHour: Double {
        let p = profile
        guard p.hourlyRate > 0, p.hoursPerWeek > 0 else { return 0 }
        let monthlyHours = p.hoursPerWeek * 4.33
        let chargesPerHour = totalChargesPerMonth / monthlyHours
        return max(0, p.hourlyRate - chargesPerHour)
    }

    static var selectedProduct: Product? {
        guard let id = selectedProductID else {
            return products.first
        }
        return products.first { $0.id == id } ?? products.first
    }

    // MARK: - Widget

    static func notifyWidget() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
