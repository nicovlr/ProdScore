import SwiftUI

struct ProductDetailView: View {
    @State var product: Product
    var onUpdate: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var isSelectedForWidget = false

    private var netPerHour: Double { DataStore.netPerHour }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                productImage
                productInfo
                progressSection
                actionButtons
                widgetToggle
                deleteButton
            }
            .padding(24)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isSelectedForWidget = DataStore.selectedProductID == product.id
        }
    }

    @ViewBuilder
    private var productImage: some View {
        if let data = product.imageData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 250)
                .cornerRadius(16)
        }
    }

    private var productInfo: some View {
        VStack(spacing: 8) {
            Text(product.name)
                .font(Theme.roundedFont(28))
                .foregroundStyle(.white)

            Text("\(Int(product.price))E")
                .font(Theme.roundedFont(22, weight: .semibold))
                .foregroundStyle(Theme.green)
        }
    }

    private var progressSection: some View {
        VStack(spacing: 12) {
            GreenProgressBar(progress: product.progress(netPerHour: netPerHour), height: 12)

            let remaining = product.hoursRemaining(netPerHour: netPerHour)
            Text(MotivationalMessages.message(hoursRemaining: remaining, productName: product.name))
                .font(Theme.roundedFont(16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            HStack {
                VStack {
                    Text(String(format: "%.1f", product.hoursWorked))
                        .font(Theme.roundedFont(24))
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                    Text("heures faites")
                        .font(Theme.roundedFont(12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                VStack {
                    let needed = product.hoursNeeded(netPerHour: netPerHour)
                    Text(needed.isFinite ? String(format: "%.1f", needed) : "---")
                        .font(Theme.roundedFont(24))
                        .foregroundStyle(.white)
                    Text("heures necessaires")
                        .font(Theme.roundedFont(12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(20)
        .background(Theme.cardBackground)
        .cornerRadius(Theme.cornerRadius)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button { addHours(0.5) } label: {
                Text("+0.5h")
                    .font(Theme.roundedFont(16))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
            }

            Button { addHours(1) } label: {
                Text("+1h")
                    .font(Theme.roundedFont(18))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.green)
                    .cornerRadius(12)
            }
        }
    }

    private var widgetToggle: some View {
        Button {
            DataStore.selectedProductID = product.id
            isSelectedForWidget = true
            DataStore.notifyWidget()
        } label: {
            HStack {
                Image(systemName: isSelectedForWidget ? "checkmark.circle.fill" : "circle")
                Text("Afficher dans le widget")
            }
            .font(Theme.roundedFont(14, weight: .medium))
            .foregroundStyle(isSelectedForWidget ? Theme.green : .white.opacity(0.5))
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            deleteProduct()
        } label: {
            Text("Supprimer")
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.red.opacity(0.8))
        }
        .padding(.top, 8)
    }

    private func addHours(_ hours: Double) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            product.hoursWorked += hours
        }

        var products = DataStore.products
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index].hoursWorked = product.hoursWorked
            DataStore.products = products
            DataStore.notifyWidget()
            onUpdate()
        }
    }

    private func deleteProduct() {
        var products = DataStore.products
        products.removeAll { $0.id == product.id }
        DataStore.products = products
        if DataStore.selectedProductID == product.id {
            DataStore.selectedProductID = products.first?.id
        }
        DataStore.notifyWidget()
        onUpdate()
        dismiss()
    }
}
