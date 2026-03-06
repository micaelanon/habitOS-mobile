import Foundation

nonisolated struct StreakPoint: Identifiable, Sendable {
    let id: UUID
    let dayLabel: String
    let streakValue: Int
}
