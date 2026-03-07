import Foundation

// DailyTask → replaced by DailyTaskItem (DataModels.swift)
// ChatMessage → replaced by CoachMessage (DataModels.swift)

nonisolated struct WeeklySummary: Sendable {
    let adherencePercent: Int
    let currentWeightKg: Double
    let weightDeltaKg: Double
    let avgWaterLiters: Double
    let avgSteps: Int
}

nonisolated struct NextMeal: Sendable {
    let mealName: String
    let timeRange: String
    let items: [String]
}
