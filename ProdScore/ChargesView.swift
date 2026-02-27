import SwiftUI

struct ChargesView: View {
    @Environment(\.dismiss) private var dismiss
    var onUpdate: () -> Void

    @State private var charges = DataStore.charges
    @State private var newName = ""
    @State private var newAmount = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                addChargeRow

                List {
                    ForEach(charges) { charge in
                        HStack {
                            Text(charge.name)
                                .font(Theme.roundedFont(16, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(Int(charge.amountPerMonth))E/mois")
                                .font(Theme.roundedFont(14, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .listRowBackground(Theme.cardBackground)
                    }
                    .onDelete(perform: deleteCharge)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)

                totalRow
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Charges mensuelles")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("OK") { dismiss() }
                        .font(.body.bold())
                        .foregroundStyle(Theme.green)
                }
            }
        }
    }

    private var addChargeRow: some View {
        HStack(spacing: 12) {
            TextField("Nom", text: $newName)
                .font(Theme.roundedFont(16, weight: .medium))
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .foregroundStyle(.white)

            TextField("E/mois", text: $newAmount)
                .keyboardType(.decimalPad)
                .font(Theme.roundedFont(16, weight: .medium))
                .frame(width: 100)
                .padding(12)
                .background(Theme.cardBackground)
                .cornerRadius(10)
                .foregroundStyle(.white)

            Button {
                addCharge()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.green)
            }
            .disabled(newName.isEmpty || (Double(newAmount.replacingOccurrences(of: ",", with: ".")) ?? 0) <= 0)
        }
        .padding(16)
    }

    private var totalRow: some View {
        HStack {
            Text("Total")
                .font(Theme.roundedFont(16))
                .foregroundStyle(.white)
            Spacer()
            Text("\(Int(charges.reduce(0) { $0 + $1.amountPerMonth }))E/mois")
                .font(Theme.roundedFont(18))
                .foregroundStyle(Theme.green)
        }
        .padding(16)
        .background(Theme.cardBackground)
    }

    private func addCharge() {
        let amount = Double(newAmount.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard !newName.isEmpty, amount > 0 else { return }
        let charge = Charge(name: newName, amountPerMonth: amount)
        charges.append(charge)
        DataStore.charges = charges
        DataStore.notifyWidget()
        onUpdate()
        newName = ""
        newAmount = ""
    }

    private func deleteCharge(at offsets: IndexSet) {
        charges.remove(atOffsets: offsets)
        DataStore.charges = charges
        DataStore.notifyWidget()
        onUpdate()
    }
}
