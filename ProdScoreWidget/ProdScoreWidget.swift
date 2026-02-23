import WidgetKit
import SwiftUI

// MARK: - Timeline

struct ScoreEntry: TimelineEntry {
    let date: Date
    let score: Int
    let message: String
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ScoreEntry {
        ScoreEntry(date: .now, score: 42, message: "Go go go!")
    }

    func getSnapshot(in context: Context, completion: @escaping (ScoreEntry) -> Void) {
        completion(ScoreEntry(
            date: .now,
            score: ScoreManager.score,
            message: ScoreManager.message
        ))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScoreEntry>) -> Void) {
        let entry = ScoreEntry(
            date: .now,
            score: ScoreManager.score,
            message: ScoreManager.message
        )
        completion(Timeline(entries: [entry], policy: .atEnd))
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: ScoreEntry

    var body: some View {
        VStack(spacing: 4) {
            Text("\(entry.score)")
                .font(.system(size: 52, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)

            Text("Prod")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Medium Widget (expanded)

struct MediumWidgetView: View {
    let entry: ScoreEntry

    var body: some View {
        HStack(spacing: 0) {
            // Score side
            VStack(spacing: 4) {
                Text("\(entry.score)")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.5)

                Text("Prod")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Divider
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(width: 1)
                .padding(.vertical, 16)

            // Message side
            VStack(alignment: .leading, spacing: 6) {
                Text("Message")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))

                if entry.message.isEmpty {
                    Text("Aucun message")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.3))
                        .italic()
                } else {
                    Text(entry.message)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(3)
                }

                Spacer()

                Text("Score: \(entry.score)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding(.leading, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

// MARK: - Entry View

struct ProdScoreWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
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
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ProdScoreWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Prod Score")
        .description("Affiche ton score de productivité.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
