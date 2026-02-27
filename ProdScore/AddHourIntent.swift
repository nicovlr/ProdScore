import AppIntents
import WidgetKit

struct AddHourIntent: AppIntent {
    static var title: LocalizedStringResource = "Ajouter une heure"
    static var description = IntentDescription("Ajoute une heure de travail au produit selectionne")

    @Parameter(title: "Heures")
    var hours: Double

    init() {
        self.hours = 1.0
    }

    init(hours: Double) {
        self.hours = hours
    }

    func perform() async throws -> some IntentResult {
        var products = DataStore.products
        guard let selected = DataStore.selectedProduct,
              let index = products.firstIndex(where: { $0.id == selected.id }) else {
            return .result()
        }
        products[index].hoursWorked += hours
        DataStore.products = products
        DataStore.notifyWidget()
        return .result()
    }
}
