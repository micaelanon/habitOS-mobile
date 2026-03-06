import Foundation

nonisolated struct MealPlan: Identifiable, Sendable {
    let id: UUID
    let userID: UUID
    let title: String
    let meals: [MealPlanEntry]
}

nonisolated struct MealPlanEntry: Identifiable, Sendable {
    let id: UUID
    let mealName: String
    let items: [String]
}
