import Foundation

nonisolated struct UserProfile: Identifiable, Sendable {
    let id: UUID
    let email: String
    let firstName: String
    let lastName: String
    let avatarURL: String?
    let goal: String?
    let currentWeightKg: Double?
    let targetWeightKg: Double?
    let heightCm: Double?
    let coachName: String?
}
