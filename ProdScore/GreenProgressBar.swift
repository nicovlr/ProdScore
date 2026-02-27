import SwiftUI

struct GreenProgressBar: View {
    let progress: Double
    var height: CGFloat = 8

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))

                Capsule()
                    .fill(Theme.green)
                    .frame(width: max(0, geo.size.width * min(1, progress)))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}
