import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var score: Int = ScoreManager.score
    @State private var message: String = ScoreManager.message

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                // Score
                VStack(spacing: 8) {
                    Text("\(score)")
                        .font(.system(size: 100, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.snappy, value: score)

                    Text("Prod")
                        .font(.title2.bold())
                        .foregroundColor(.gray)
                }

                // +/- buttons
                HStack(spacing: 48) {
                    Button {
                        score -= 1
                        save()
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }

                    Button {
                        score = 0
                        save()
                    } label: {
                        Text("RAZ")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    Button {
                        score += 1
                        save()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                    }
                }

                // Message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message")
                        .font(.caption.bold())
                        .foregroundColor(.gray)

                    TextField("Ton message...", text: $message)
                        .textFieldStyle(.plain)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.white)
                        .onChange(of: message) { _ in
                            save()
                        }
                }
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private func save() {
        ScoreManager.score = score
        ScoreManager.message = message
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    ContentView()
}
