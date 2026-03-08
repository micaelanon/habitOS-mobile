import Foundation

/// A single memory item the coach has about the user.
/// Maps to `coach_facts` table in Supabase.
struct CoachMemory: Identifiable, Decodable {
    let id: UUID
    let profileId: UUID
    let factKind: String
    let title: String
    let factText: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title
        case profileId = "profile_id"
        case factKind = "fact_kind"
        case factText = "fact_text"
        case createdAt = "created_at"
    }

    /// Display-friendly category in Spanish, derived from fact_kind enum.
    var category: String {
        switch factKind {
        case "body": return "Cuerpo"
        case "goal": return "Objetivos"
        case "preference": return "Preferencias"
        case "restriction", "allergy": return "Restricciones"
        case "context", "schedule": return "Historial"
        case "habit": return "Hábitos"
        case "medical": return "Médico"
        default: return "Otros"
        }
    }

    /// Display text for views that referenced the old `fact` property.
    var fact: String { factText }
}
