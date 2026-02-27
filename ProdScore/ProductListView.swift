import SwiftUI

struct ProductListView: View {
    @State private var products = DataStore.products
    @State private var showAddProduct = false
    @State private var showSettings = false

    private var netPerHour: Double { DataStore.netPerHour }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if products.isEmpty {
                        emptyState
                    } else {
                        ForEach(products) { product in
                            NavigationLink(destination: ProductDetailView(product: product, onUpdate: refresh)) {
                                ProductCardView(product: product, netPerHour: netPerHour)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Mes objectifs")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddProduct = true } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Theme.green)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddProduct) {
                AddProductView(onSave: refresh)
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(onUpdate: refresh)
            }
            .onAppear { refresh() }
        }
        .preferredColorScheme(.dark)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Text("Aucun objectif")
                .font(Theme.roundedFont(20))
                .foregroundStyle(.white)
            Text("Ajoute un produit pour commencer a tracker tes heures de travail.")
                .font(Theme.roundedFont(14, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
            Button {
                showAddProduct = true
            } label: {
                Text("Ajouter un produit")
                    .font(Theme.roundedFont(16))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Theme.green)
                    .cornerRadius(12)
            }
        }
        .padding(.top, 80)
    }

    private func refresh() {
        products = DataStore.products
    }
}
