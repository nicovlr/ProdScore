import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var step = 0
    @State private var hourlyRate = ""
    @State private var hoursPerWeek = ""

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            if step == 0 {
                welcomeStep
            } else {
                profileStep
            }

            Spacer()

            Button {
                if step == 0 {
                    withAnimation { step = 1 }
                } else {
                    save()
                }
            } label: {
                Text(step == 0 ? "C'est parti !" : "Commencer")
                    .font(Theme.roundedFont(18))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.green)
                    .cornerRadius(16)
            }
            .disabled(step == 1 && !isValid)
            .opacity(step == 1 && !isValid ? 0.5 : 1)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.black.ignoresSafeArea())
    }

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Text("Objectif Epargne")
                .font(Theme.roundedFont(32))
                .foregroundStyle(.white)
            Text("Decouvre combien d'heures de travail il te faut pour t'acheter ce qui te fait envie.")
                .font(Theme.roundedFont(16, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }

    private var profileStep: some View {
        VStack(spacing: 24) {
            Text("Ton profil")
                .font(Theme.roundedFont(28))
                .foregroundStyle(.white)

            VStack(spacing: 16) {
                fieldBlock(label: "Taux horaire (euros)", placeholder: "ex: 25", text: $hourlyRate)
                fieldBlock(label: "Heures par semaine", placeholder: "ex: 35", text: $hoursPerWeek)
            }
            .padding(.horizontal, 24)
        }
    }

    private func fieldBlock(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            TextField(placeholder, text: text)
                .keyboardType(.decimalPad)
                .font(Theme.roundedFont(20))
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .foregroundStyle(.white)
        }
    }

    private var isValid: Bool {
        guard let rate = Double(hourlyRate.replacingOccurrences(of: ",", with: ".")),
              let hours = Double(hoursPerWeek.replacingOccurrences(of: ",", with: ".")) else {
            return false
        }
        return rate > 0 && hours > 0
    }

    private func save() {
        let rate = Double(hourlyRate.replacingOccurrences(of: ",", with: ".")) ?? 0
        let hours = Double(hoursPerWeek.replacingOccurrences(of: ",", with: ".")) ?? 0
        var profile = DataStore.profile
        profile.hourlyRate = rate
        profile.hoursPerWeek = hours
        profile.hasCompletedOnboarding = true
        DataStore.profile = profile
        DataStore.notifyWidget()
        onComplete()
    }
}
