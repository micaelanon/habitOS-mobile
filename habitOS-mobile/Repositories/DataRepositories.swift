import Foundation
import Supabase

/// Diet repository — reads nutrition plans and logs meals
final class DietRepository: DietRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func fetchActivePlan(userId: UUID) async throws -> NutritionPlan? {
        let plans: [NutritionPlan] = try await client.database
            .from("nutrition_plans")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "active")
            .order("created_at", ascending: false)
            .limit(1)
            .execute()
            .value
        return plans.first
    }

    func logMeal(_ log: MealLog) async throws {
        try await client.database
            .from("meal_logs")
            .insert(log)
            .execute()
    }

    func fetchMealLogs(userId: UUID, date: Date) async throws -> [MealLog] {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let logs: [MealLog] = try await client.database
            .from("meal_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("logged_at", value: ISO8601DateFormatter().string(from: startOfDay))
            .lt("logged_at", value: ISO8601DateFormatter().string(from: endOfDay))
            .order("logged_at")
            .execute()
            .value
        return logs
    }
}

/// Journal repository
final class JournalRepository: JournalRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func fetchEntry(userId: UUID, date: Date) async throws -> JournalEntry? {
        let dateStr = Self.dateFormatter.string(from: date)
        let entries: [JournalEntry] = try await client.database
            .from("journal_entries")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("entry_date", value: dateStr)
            .limit(1)
            .execute()
            .value
        return entries.first
    }

    func saveEntry(_ entry: JournalEntry) async throws {
        try await client.database
            .from("journal_entries")
            .upsert(entry)
            .execute()
    }

    func fetchEntries(userId: UUID, from: Date, to: Date) async throws -> [JournalEntry] {
        let fromStr = Self.dateFormatter.string(from: from)
        let toStr = Self.dateFormatter.string(from: to)
        let entries: [JournalEntry] = try await client.database
            .from("journal_entries")
            .select()
            .eq("user_id", value: userId.uuidString)
            .gte("entry_date", value: fromStr)
            .lte("entry_date", value: toStr)
            .order("entry_date", ascending: false)
            .execute()
            .value
        return entries
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}

/// Weight tracking repository
final class TrackingRepository: TrackingRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func fetchWeightLogs(userId: UUID, limit: Int) async throws -> [WeightLog] {
        let logs: [WeightLog] = try await client.database
            .from("weight_logs")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("logged_at", ascending: false)
            .limit(limit)
            .execute()
            .value
        return logs
    }

    func logWeight(_ log: WeightLog) async throws {
        try await client.database
            .from("weight_logs")
            .insert(log)
            .execute()
    }

    func deleteWeightLog(id: UUID) async throws {
        try await client.database
            .from("weight_logs")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }
}

/// Daily tasks repository
final class TaskRepository: TaskRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func fetchTasks(userId: UUID, date: Date) async throws -> [DailyTaskItem] {
        let dateStr = Self.dateFormatter.string(from: date)
        let tasks: [DailyTaskItem] = try await client.database
            .from("daily_tasks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("task_date", value: dateStr)
            .order("sort_order")
            .execute()
            .value
        return tasks
    }

    func toggleTask(id: UUID, completed: Bool) async throws {
        struct TaskUpdate: Codable {
            let isCompleted: Bool
            let completedAt: Date?
            enum CodingKeys: String, CodingKey {
                case isCompleted = "is_completed"
                case completedAt = "completed_at"
            }
        }
        try await client.database
            .from("daily_tasks")
            .update(TaskUpdate(isCompleted: completed, completedAt: completed ? Date() : nil))
            .eq("id", value: id.uuidString)
            .execute()
    }

    func createTask(_ task: DailyTaskItem) async throws {
        try await client.database
            .from("daily_tasks")
            .insert(task)
            .execute()
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
