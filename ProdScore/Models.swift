import Foundation

struct UserProfile: Codable {
    var hourlyRate: Double
    var hoursPerWeek: Double
    var hasCompletedOnboarding: Bool

    static let `default` = UserProfile(hourlyRate: 0, hoursPerWeek: 35, hasCompletedOnboarding: false)
}

struct Charge: Codable, Identifiable {
    var id: UUID
    var name: String
    var amountPerMonth: Double

    init(id: UUID = UUID(), name: String, amountPerMonth: Double) {
        self.id = id
        self.name = name
        self.amountPerMonth = amountPerMonth
    }
}

struct Product: Codable, Identifiable {
    var id: UUID
    var name: String
    var price: Double
    var imageURL: String?
    var imageData: Data?
    var sourceURL: String?
    var hoursWorked: Double
    var createdAt: Date

    init(id: UUID = UUID(), name: String, price: Double, imageURL: String? = nil, imageData: Data? = nil, sourceURL: String? = nil, hoursWorked: Double = 0, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.price = price
        self.imageURL = imageURL
        self.imageData = imageData
        self.sourceURL = sourceURL
        self.hoursWorked = hoursWorked
        self.createdAt = createdAt
    }

    func hoursNeeded(netPerHour: Double) -> Double {
        guard netPerHour > 0 else { return .infinity }
        return price / netPerHour
    }

    func hoursRemaining(netPerHour: Double) -> Double {
        max(0, hoursNeeded(netPerHour: netPerHour) - hoursWorked)
    }

    func progress(netPerHour: Double) -> Double {
        let needed = hoursNeeded(netPerHour: netPerHour)
        guard needed > 0, needed.isFinite else { return 0 }
        return min(1, hoursWorked / needed)
    }
}
