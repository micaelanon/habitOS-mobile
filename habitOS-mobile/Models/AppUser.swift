import Foundation

/// Maps `app_users` table in Supabase
struct AppUser: Codable, Identifiable, Sendable {
    let id: UUID
    let authUserId: UUID
    let coachProfileId: UUID?
    var firstName: String
    var lastName: String
    var email: String
    var phone: String?
    var avatarUrl: String?
    var sex: String?
    var dateOfBirth: Date?
    var heightCm: Double?
    var currentWeightKg: Double?
    var goal: String?
    var activityLevel: String?
    var foodAllergies: [String]
    var foodDislikes: [String]
    var dietType: String?
    var medicalConditions: [String]
    var timezone: String
    var locale: String
    var notificationsEnabled: Bool
    var healthkitEnabled: Bool
    var onboardingCompleted: Bool
    let createdAt: Date
    var updatedAt: Date

    var fullName: String { "\(firstName) \(lastName)" }

    enum CodingKeys: String, CodingKey {
        case id
        case authUserId = "auth_user_id"
        case coachProfileId = "coach_profile_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case email, phone
        case avatarUrl = "avatar_url"
        case sex
        case dateOfBirth = "date_of_birth"
        case heightCm = "height_cm"
        case currentWeightKg = "current_weight_kg"
        case goal
        case activityLevel = "activity_level"
        case foodAllergies = "food_allergies"
        case foodDislikes = "food_dislikes"
        case dietType = "diet_type"
        case medicalConditions = "medical_conditions"
        case timezone, locale
        case notificationsEnabled = "notifications_enabled"
        case healthkitEnabled = "healthkit_enabled"
        case onboardingCompleted = "onboarding_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - View Compatibility

extension AppUser {
    /// Coach name — requires fetching CoachProfile via coachProfileId.
    /// Returns nil when the relationship is not yet resolved.
    var coachName: String? { nil }

    /// Target weight — lives in the active NutritionPlan or user goals, not on app_users.
    var targetWeightKg: Double? { nil }

    /// Parsed avatar URL from the stored string.
    var avatarURL: URL? { avatarUrl.flatMap { URL(string: $0) } }
}
