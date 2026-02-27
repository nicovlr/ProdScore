import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry

struct ProductEntry: TimelineEntry {
    let date: Date
    let productName: String
    let price: Double
    let hoursWorked: Double
    let hoursNeeded: Double
    let progress: Double
    let imageData: Data?
    let message: String

    var hoursRemaining: Double { max(0, hoursNeeded - hoursWorked) }

    static let placeholder = ProductEntry(
        date: .now,
        productName: "MacBook Pro",
        price: 1999,
        hoursWorked: 30,
        hoursNeeded: 80,
        progress: 0.375,
        imageData: nil,
        message: "Plus que 50h de taff !"
    )
}

// MARK: - Provider

struct ProductProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProductEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProductEntry) -> Void) {
        completion(makeEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProductEntry>) -> Void) {
        let entry = makeEntry()
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private func makeEntry() -> ProductEntry {
        let netPerHour = DataStore.netPerHour
        guard let product = DataStore.selectedProduct, netPerHour > 0 else {
            return ProductEntry(
                date: .now,
                productName: "Aucun produit",
                price: 0,
                hoursWorked: 0,
                hoursNeeded: 0,
                progress: 0,
                imageData: nil,
                message: "Ouvre l'app pour commencer"
            )
        }

        let needed = product.hoursNeeded(netPerHour: netPerHour)
        let remaining = product.hoursRemaining(netPerHour: netPerHour)

        return ProductEntry(
            date: .now,
            productName: product.name,
            price: product.price,
            hoursWorked: product.hoursWorked,
            hoursNeeded: needed,
            progress: product.progress(netPerHour: netPerHour),
            imageData: product.imageData,
            message: MotivationalMessages.message(hoursRemaining: remaining, productName: product.name)
        )
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: ProductEntry

    var body: some View {
        VStack(spacing: 8) {
            Spacer()

            GreenProgressBar(progress: entry.progress, height: 8)

            Text(MotivationalMessages.shortMessage(hoursRemaining: entry.hoursRemaining))
                .font(Theme.roundedFont(13, weight: .semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.7)

            Spacer()
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: ProductEntry

    var body: some View {
        HStack(spacing: 12) {
            if let data = entry.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .cornerRadius(10)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 56, height: 56)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.productName)
                    .font(Theme.roundedFont(14))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                Text("\(Int(entry.price))E")
                    .font(Theme.roundedFont(12, weight: .semibold))
                    .foregroundStyle(Theme.green)

                GreenProgressBar(progress: entry.progress, height: 6)

                Text(entry.message)
                    .font(Theme.roundedFont(11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .lineLimit(1)
            }

            Button(intent: AddHourIntent(hours: 1)) {
                Text("+1h")
                    .font(Theme.roundedFont(14))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Theme.green)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Accessory Circular

struct AccessoryCircularView: View {
    let entry: ProductEntry

    var body: some View {
        Gauge(value: entry.progress) {
            Text("\(Int(entry.hoursRemaining))h")
                .font(.system(size: 10, weight: .bold, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Accessory Rectangular

struct AccessoryRectangularView: View {
    let entry: ProductEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.productName)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .lineLimit(1)

            ProgressView(value: entry.progress)

            Text("\(Int(entry.hoursRemaining))h restantes")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

// MARK: - Entry View

struct ProdScoreWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ProductEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget

@main
struct ProdScoreWidget: Widget {
    let kind = "ProdScoreWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ProductProvider()) { entry in
            ProdScoreWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Objectif Epargne")
        .description("Suis ta progression vers ton prochain achat.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}
