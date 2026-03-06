import Foundation

nonisolated struct Habit: Identifiable, Sendable {
    let id: UUID
    let name: String
    var isCompletedToday: Bool
    var streak: Int
    var completedAt: Date?
}
