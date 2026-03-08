import Foundation
@testable import habitOS_mobile

// MARK: - Mock Diet Repository

final class MockDietRepository: DietRepositoryProtocol, @unchecked Sendable {
    var activePlan: NutritionPlan?
    var mealLogs: [MealLog] = []
    var shouldThrow = false

    func fetchActivePlan(userId: UUID) async throws -> NutritionPlan? {
        if shouldThrow { throw MockError.forced }
        return activePlan
    }

    func logMeal(_ log: MealLog) async throws {
        if shouldThrow { throw MockError.forced }
        mealLogs.append(log)
    }

    func fetchMealLogs(userId: UUID, date: Date) async throws -> [MealLog] {
        if shouldThrow { throw MockError.forced }
        return mealLogs
    }
}

// MARK: - Mock Task Repository

final class MockTaskRepository: TaskRepositoryProtocol, @unchecked Sendable {
    var tasks: [DailyTaskItem] = []
    var shouldThrow = false

    func fetchTasks(userId: UUID, date: Date) async throws -> [DailyTaskItem] {
        if shouldThrow { throw MockError.forced }
        return tasks
    }

    func toggleTask(id: UUID, completed: Bool) async throws {
        if shouldThrow { throw MockError.forced }
        if let idx = tasks.firstIndex(where: { $0.id == id }) {
            tasks[idx].isCompleted = completed
        }
    }

    func createTask(_ task: DailyTaskItem) async throws {
        if shouldThrow { throw MockError.forced }
        tasks.append(task)
    }
}

// MARK: - Mock Chat Repository

final class MockChatRepository: ChatRepositoryProtocol, @unchecked Sendable {
    var messages: [CoachMessage] = []
    var shouldThrow = false

    func fetchMessages(profileId: UUID, limit: Int) async throws -> [CoachMessage] {
        if shouldThrow { throw MockError.forced }
        return Array(messages.prefix(limit))
    }

    func sendMessage(profileId: UUID, text: String) async throws -> CoachMessage {
        if shouldThrow { throw MockError.forced }
        let msg = CoachMessage(
            id: UUID(),
            profileId: profileId,
            role: .user,
            channel: "app",
            messageText: text,
            mediaType: nil,
            mediaUrl: nil,
            metadata: nil,
            expiresAt: nil,
            createdAt: Date()
        )
        messages.append(msg)
        return msg
    }

    func subscribeToMessages(profileId: UUID, onNew: @escaping (CoachMessage) -> Void) async {}
}

// MARK: - Mock Journal Repository

final class MockJournalRepository: JournalRepositoryProtocol, @unchecked Sendable {
    var entries: [JournalEntry] = []
    var shouldThrow = false

    func fetchEntry(userId: UUID, date: Date) async throws -> JournalEntry? {
        if shouldThrow { throw MockError.forced }
        return entries.first
    }

    func saveEntry(_ entry: JournalEntry) async throws {
        if shouldThrow { throw MockError.forced }
        entries.append(entry)
    }

    func fetchEntries(userId: UUID, from: Date, to: Date) async throws -> [JournalEntry] {
        if shouldThrow { throw MockError.forced }
        return entries
    }
}

// MARK: - Mock Auth Repository

final class MockAuthRepository: AuthRepositoryProtocol, @unchecked Sendable {
    var currentUser: AppUser?
    var sessionUserId: UUID?
    var shouldThrow = false

    func signInWithEmail(email: String, password: String) async throws {
        if shouldThrow { throw MockError.forced }
    }

    func signInWithMagicLink(email: String) async throws {
        if shouldThrow { throw MockError.forced }
    }

    func signOut() async throws {
        if shouldThrow { throw MockError.forced }
        currentUser = nil
        sessionUserId = nil
    }

    func getCurrentSession() async throws -> UUID? {
        if shouldThrow { throw MockError.forced }
        return sessionUserId
    }

    func fetchCurrentUser() async throws -> AppUser? {
        if shouldThrow { throw MockError.forced }
        return currentUser
    }
}

// MARK: - Shared

enum MockError: Error, LocalizedError {
    case forced
    var errorDescription: String? { "Mock forced error" }
}
