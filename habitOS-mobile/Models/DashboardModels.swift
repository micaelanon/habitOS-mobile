import Foundation

nonisolated struct DailyTask: Identifiable, Sendable {
    let id: UUID
    let title: String
    let category: TaskCategory
    var isCompleted: Bool
    var completedAt: Date?

    enum TaskCategory: String, Sendable {
        case nutrition
        case hydration
        case activity
        case sleep
        case supplement
        case habit
        case other
    }
}

nonisolated struct WeeklySummary: Sendable {
    let adherencePercent: Int
    let currentWeightKg: Double
    let weightDeltaKg: Double
    let avgWaterLiters: Double
    let avgSteps: Int
}

nonisolated struct ChatMessage: Identifiable, Sendable {
    let id: UUID
    let role: MessageRole
    let text: String
    let timestamp: Date

    enum MessageRole: String, Sendable {
        case user
        case coach
    }
}

nonisolated struct NextMeal: Sendable {
    let mealName: String
    let timeRange: String
    let items: [String]
}
