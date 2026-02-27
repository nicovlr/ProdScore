import SwiftUI

struct Theme {
    static let green = Color(red: 52 / 255, green: 199 / 255, blue: 89 / 255)
    static let cardBackground = Color.white.opacity(0.06)
    static let cornerRadius: CGFloat = 16

    static func roundedFont(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}
