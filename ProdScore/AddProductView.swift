import SwiftUI

struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: () -> Void

    @State private var name = ""
    @State private var price = ""
    @State private var sourceURL = ""
    @StateObject private var fetcher = LinkPreviewFetcher()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    linkSection
                    previewImage
                    nameSection
                    priceSection
                }
                .padding(24)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Nouveau produit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { save() }
                        .disabled(!isValid)
                        .foregroundStyle(isValid ? Theme.green : .gray)
                        .font(.body.bold())
                }
            }
            .onChange(of: fetcher.title) { _, newTitle in
                if name.isEmpty && !newTitle.isEmpty {
                    name = newTitle
                }
            }
        }
    }

    private var linkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Lien (optionnel)")
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            HStack {
                TextField("Coller un lien produit", text: $sourceURL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .font(Theme.roundedFont(16, weight: .medium))
                    .padding()
                    .background(Theme.cardBackground)
                    .cornerRadius(12)
                    .foregroundStyle(.white)

                if !sourceURL.isEmpty {
                    Button {
                        Task { await fetcher.fetch(from: sourceURL) }
                    } label: {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.green)
                    }
                }
            }

            if fetcher.isLoading {
                ProgressView()
                    .tint(Theme.green)
            }

            if let error = fetcher.error {
                Text(error)
                    .font(Theme.roundedFont(12, weight: .medium))
                    .foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var previewImage: some View {
        if let image = fetcher.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
                .cornerRadius(12)
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nom du produit")
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            TextField("ex: MacBook Pro", text: $name)
                .font(Theme.roundedFont(16, weight: .medium))
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .foregroundStyle(.white)
        }
    }

    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Prix (euros)")
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            TextField("ex: 1499", text: $price)
                .keyboardType(.decimalPad)
                .font(Theme.roundedFont(16, weight: .medium))
                .padding()
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .foregroundStyle(.white)
        }
    }

    private var isValid: Bool {
        !name.isEmpty && (Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0) > 0
    }

    private func save() {
        let priceValue = Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0
        var imageData: Data?
        if let image = fetcher.image {
            imageData = image.jpegData(compressionQuality: 0.7)
        }
        let product = Product(
            name: name,
            price: priceValue,
            imageData: imageData,
            sourceURL: sourceURL.isEmpty ? nil : sourceURL
        )
        var products = DataStore.products
        products.append(product)
        DataStore.products = products
        if DataStore.selectedProductID == nil {
            DataStore.selectedProductID = product.id
        }
        DataStore.notifyWidget()
        onSave()
        dismiss()
    }
}
