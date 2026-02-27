import Foundation

struct MotivationalMessages {
    static func message(hoursRemaining: Double, productName: String) -> String {
        if hoursRemaining <= 0 {
            return "C'est dans la poche !"
        } else if hoursRemaining <= 1 {
            return "Allez, dernier effort !"
        } else if hoursRemaining <= 4 {
            return "Plus que \(formatted(hoursRemaining)) de taff !"
        } else if hoursRemaining <= 8 {
            return "Une journee et c'est bon !"
        } else if hoursRemaining <= 16 {
            return "Deux jours max, tu geres !"
        } else if hoursRemaining <= 40 {
            return "Une semaine de hustle !"
        } else {
            return "Le \(productName) arrive bientot !"
        }
    }

    static func shortMessage(hoursRemaining: Double) -> String {
        if hoursRemaining <= 0 {
            return "Objectif atteint !"
        } else if hoursRemaining <= 1 {
            return "Presque !"
        } else if hoursRemaining <= 8 {
            return "Encore \(formatted(hoursRemaining)) !"
        } else {
            return "\(formatted(hoursRemaining)) restantes"
        }
    }

    private static func formatted(_ hours: Double) -> String {
        if hours == hours.rounded() {
            return "\(Int(hours))h"
        }
        return String(format: "%.1fh", hours)
    }
}
