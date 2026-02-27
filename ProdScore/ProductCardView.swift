import SwiftUI

struct ProductCardView: View {
    let product: Product
    let netPerHour: Double

    var body: some View {
        HStack(spacing: 12) {
            productImage

            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(Theme.roundedFont(16))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                HStack {
                    Text("\(Int(product.price))E")
                        .font(Theme.roundedFont(14, weight: .semibold))
                        .foregroundStyle(Theme.green)

                    Spacer()

                    let remaining = product.hoursRemaining(netPerHour: netPerHour)
                    if remaining <= 0 {
                        Text("Atteint !")
                            .font(Theme.roundedFont(12, weight: .semibold))
                            .foregroundStyle(Theme.green)
                    } else {
                        Text("\(formatted(remaining)) restantes")
                            .font(Theme.roundedFont(12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }

                GreenProgressBar(progress: product.progress(netPerHour: netPerHour), height: 6)
            }
        }
        .padding(12)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }

    @ViewBuilder
    private var productImage: some View {
        if let data = product.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .cornerRadius(12)
                .clipped()
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .frame(width: 60, height: 60)
        }
    }

    private func formatted(_ hours: Double) -> String {
        if hours >= 1 && hours == hours.rounded() {
            return "\(Int(hours))h"
        }
        return String(format: "%.1fh", hours)
    }
}
