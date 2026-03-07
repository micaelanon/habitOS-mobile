import Foundation

/// Maps `nutrition_plans` table in Supabase
struct NutritionPlan: Codable, Identifiable, Sendable {
    let id: UUID
    let userId: UUID
    var planName: String
    var status: String // draft, active, paused, completed, archived
    var startDate: Date
    var endDate: Date?
    var dailyCalories: Int?
    var dailyProteinG: Int?
    var dailyCarbsG: Int?
    var dailyFatsG: Int?
    var dailyFiberG: Int?
    var mealCount: Int
    var guidelines: String?
    var mealPlan: MealPlanData // JSONB
    var aiGenerated: Bool
    var createdBy: String?
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case planName = "plan_name"
        case status
        case startDate = "start_date"
        case endDate = "end_date"
        case dailyCalories = "daily_calories"
        case dailyProteinG = "daily_protein_g"
        case dailyCarbsG = "daily_carbs_g"
        case dailyFatsG = "daily_fats_g"
        case dailyFiberG = "daily_fiber_g"
        case mealCount = "meal_count"
        case guidelines
        case mealPlan = "meal_plan"
        case aiGenerated = "ai_generated"
        case createdBy = "created_by"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// JSONB structure for the weekly meal plan
struct MealPlanData: Codable, Sendable {
    var monday: DayMeals?
    var tuesday: DayMeals?
    var wednesday: DayMeals?
    var thursday: DayMeals?
    var friday: DayMeals?
    var saturday: DayMeals?
    var sunday: DayMeals?

    func meals(for dayOfWeek: Int) -> DayMeals? {
        switch dayOfWeek {
        case 2: return monday
        case 3: return tuesday
        case 4: return wednesday
        case 5: return thursday
        case 6: return friday
        case 7: return saturday
        case 1: return sunday
        default: return nil
        }
    }
}

struct DayMeals: Codable, Sendable {
    var breakfast: MealDetail?
    var midMorning: MealDetail?
    var lunch: MealDetail?
    var snack: MealDetail?
    var dinner: MealDetail?

    enum CodingKeys: String, CodingKey {
        case breakfast
        case midMorning = "mid_morning"
        case lunch, snack, dinner
    }

    var allMeals: [(type: String, meal: MealDetail)] {
        var result: [(String, MealDetail)] = []
        if let m = breakfast { result.append(("Desayuno", m)) }
        if let m = midMorning { result.append(("Media Mañana", m)) }
        if let m = lunch { result.append(("Almuerzo", m)) }
        if let m = snack { result.append(("Merienda", m)) }
        if let m = dinner { result.append(("Cena", m)) }
        return result
    }
}

struct MealDetail: Codable, Identifiable, Sendable {
    var id: UUID { UUID() }
    var name: String
    var time: String?
    var calories: Int?
    var proteinG: Int?
    var carbsG: Int?
    var fatsG: Int?
    var fiberG: Int?
    var ingredients: [MealIngredient]?
    var instructions: String?
    var prepTimeMinutes: Int?
    var imageUrl: String?
    var alternatives: [String]?

    enum CodingKeys: String, CodingKey {
        case name, time, calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatsG = "fats_g"
        case fiberG = "fiber_g"
        case ingredients, instructions
        case prepTimeMinutes = "prep_time_minutes"
        case imageUrl = "image_url"
        case alternatives
    }
}

struct MealIngredient: Codable, Identifiable, Sendable {
    var id: UUID { UUID() }
    var name: String
    var quantity: String?
    var grams: Double?

    enum CodingKeys: String, CodingKey {
        case name, quantity, grams
    }
}
