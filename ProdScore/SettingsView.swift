import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    var onUpdate: () -> Void

    @State private var hourlyRate = ""
    @State private var hoursPerWeek = ""
    @State private var showCharges = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    fieldBlock(label: "Taux horaire (euros)", placeholder: "ex: 25", text: $hourlyRate)
                    fieldBlock(label: "Heures par semaine", placeholder: "ex: 35", text: $hoursPerWeek)

                    let net = computeNetPerHour()
                    if net > 0 {
                        HStack {
                            Text("Taux net effectif")
                                .font(Theme.roundedFont(14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.6))
                            Spacer()
                            Text(String(format: "%.2fE/h", net))
                                .font(Theme.roundedFont(16))
                                .foregroundStyle(Theme.green)
                        }
                        .padding(16)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                    }

                    Button { showCharges = true } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Gerer les charges mensuelles")
                            Spacer()
                            Text("\(Int(DataStore.totalChargesPerMonth))E/mois")
                                .foregroundStyle(.white.opacity(0.5))
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white.opacity(0.3))
                        }
                        .font(Theme.roundedFont(16, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(Theme.cardBackground)
                        .cornerRadius(12)
                    }

                    Button(role: .destructive) {
                        resetOnboarding()
                    } label: {
                        Text("Reinitialiser l'onboarding")
                            .font(Theme.roundedFont(14, weight: .medium))
                            .foregroundStyle(.red.opacity(0.6))
                    }
                    .padding(.top, 16)
                }
                .padding(24)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Reglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { save() }
                        .font(.body.bold())
                        .foregroundStyle(Theme.green)
                }
            }
            .sheet(isPresented: $showCharges) {
                ChargesView(onUpdate: onUpdate)
            }
            .onAppear {
                let profile = DataStore.profile
                hourlyRate = profile.hourlyRate > 0 ? String(format: "%.2f", profile.hourlyRate) : ""
                hoursPerWeek = profile.hoursPerWeek > 0 ? String(format: "%.0f", profile.hoursPerWeek) : ""
            }
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

    private func computeNetPerHour() -> Double {
        let rate = Double(hourlyRate.replacingOccurrences(of: ",", with: ".")) ?? 0
        let hours = Double(hoursPerWeek.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard rate > 0, hours > 0 else { return 0 }
        let monthlyHours = hours * 4.33
        return max(0, rate - DataStore.totalChargesPerMonth / monthlyHours)
    }

    private func save() {
        let rate = Double(hourlyRate.replacingOccurrences(of: ",", with: ".")) ?? 0
        let hours = Double(hoursPerWeek.replacingOccurrences(of: ",", with: ".")) ?? 0
        var profile = DataStore.profile
        profile.hourlyRate = rate
        profile.hoursPerWeek = hours
        DataStore.profile = profile
        DataStore.notifyWidget()
        onUpdate()
        dismiss()
    }

    private func resetOnboarding() {
        var profile = DataStore.profile
        profile.hasCompletedOnboarding = false
        DataStore.profile = profile
        onUpdate()
        dismiss()
    }
}
