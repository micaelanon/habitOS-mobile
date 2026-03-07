import Foundation

/// A single memory item the coach has about the user
struct CoachMemory: Identifiable, Decodable {
    let id: UUID
    let userId: UUID
    let category: String
    let fact: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, category, fact
        case userId = "user_id"
        case createdAt = "created_at"
    }
}
