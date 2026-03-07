import SwiftUI

/// Shopping List ViewModel — auto-generates items from the weekly meal plan
@Observable
final class ShoppingListViewModel {
    var items: [ShoppingCategory] = []
    var isLoading: Bool = false
    var checkedCount: Int { items.flatMap(\.items).filter(\.checked).count }
    var totalCount: Int { items.flatMap(\.items).count }

    struct ShoppingCategory: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        var items: [ShoppingItemUI]
    }

    struct ShoppingItemUI: Identifiable {
        let id = UUID()
        let name: String
        let quantity: String
        var checked: Bool = false
    }

    func loadFromMealPlan() {
        isLoading = true
        defer { isLoading = false }

        items = [
            ShoppingCategory(name: "Proteínas", icon: "🥩", items: [
                ShoppingItemUI(name: "Pechuga de pollo", quantity: "1.4 kg"),
                ShoppingItemUI(name: "Salmón fresco", quantity: "1.26 kg"),
                ShoppingItemUI(name: "Claras de huevo", quantity: "21 uds"),
            ]),
            ShoppingCategory(name: "Lácteos", icon: "🥛", items: [
                ShoppingItemUI(name: "Yogur griego natural", quantity: "7 uds"),
                ShoppingItemUI(name: "Leche desnatada", quantity: "1 L"),
            ]),
            ShoppingCategory(name: "Cereales y Pan", icon: "🍞", items: [
                ShoppingItemUI(name: "Pan integral", quantity: "14 rebanadas"),
                ShoppingItemUI(name: "Arroz integral", quantity: "1.05 kg"),
                ShoppingItemUI(name: "Tortitas de arroz", quantity: "14 uds"),
            ]),
            ShoppingCategory(name: "Frutas", icon: "🍌", items: [
                ShoppingItemUI(name: "Plátanos", quantity: "7 uds"),
                ShoppingItemUI(name: "Aguacate", quantity: "2 uds"),
            ]),
            ShoppingCategory(name: "Verduras", icon: "🥦", items: [
                ShoppingItemUI(name: "Mezcla de lechugas", quantity: "700 g"),
                ShoppingItemUI(name: "Tomate cherry", quantity: "350 g"),
                ShoppingItemUI(name: "Brócoli", quantity: "700 g"),
                ShoppingItemUI(name: "Espárragos", quantity: "560 g"),
                ShoppingItemUI(name: "Camote / boniato", quantity: "1.05 kg"),
            ]),
            ShoppingCategory(name: "Frutos secos", icon: "🥜", items: [
                ShoppingItemUI(name: "Nueces", quantity: "105 g"),
            ]),
            ShoppingCategory(name: "Aceites y Condimentos", icon: "🫒", items: [
                ShoppingItemUI(name: "AOVE", quantity: "1 botella"),
                ShoppingItemUI(name: "Café", quantity: "según consumo"),
            ]),
        ]
    }

    func toggleItem(categoryId: UUID, itemId: UUID) {
        guard let ci = items.firstIndex(where: { $0.id == categoryId }),
              let ii = items[ci].items.firstIndex(where: { $0.id == itemId }) else { return }
        items[ci].items[ii].checked.toggle()
    }

    func uncheckAll() {
        for ci in items.indices {
            for ii in items[ci].items.indices {
                items[ci].items[ii].checked = false
            }
        }
    }
}
