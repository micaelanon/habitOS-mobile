import Foundation
import UIKit

/// Repository protocols for dependency injection and testability
/// Each protocol defines CRUD operations for a Supabase table

// MARK: – Auth

protocol AuthRepositoryProtocol: Sendable {
    func signInWithEmail(email: String, password: String) async throws
    func signInWithMagicLink(email: String) async throws
    func signOut() async throws
    func getCurrentSession() async throws -> UUID? // returns auth user ID
    func fetchCurrentUser() async throws -> AppUser?
}

// MARK: – Diet

protocol DietRepositoryProtocol: Sendable {
    func fetchActivePlan(userId: UUID) async throws -> NutritionPlan?
    func logMeal(_ log: MealLog) async throws
    func fetchMealLogs(userId: UUID, date: Date) async throws -> [MealLog]
}

// MARK: – Chat

protocol ChatRepositoryProtocol: Sendable {
    func fetchMessages(profileId: UUID, limit: Int) async throws -> [CoachMessage]
    func sendMessage(profileId: UUID, text: String) async throws -> CoachMessage
    func subscribeToMessages(profileId: UUID, onNew: @escaping (CoachMessage) -> Void) async
}

// MARK: – Journal

protocol JournalRepositoryProtocol: Sendable {
    func fetchEntry(userId: UUID, date: Date) async throws -> JournalEntry?
    func saveEntry(_ entry: JournalEntry) async throws
    func fetchEntries(userId: UUID, from: Date, to: Date) async throws -> [JournalEntry]
}

// MARK: – Tracking (Weight, Photos)

protocol TrackingRepositoryProtocol: Sendable {
    func fetchWeightLogs(userId: UUID, limit: Int) async throws -> [WeightLog]
    func logWeight(_ log: WeightLog) async throws
    func deleteWeightLog(id: UUID) async throws
}

// MARK: – Tasks

protocol TaskRepositoryProtocol: Sendable {
    func fetchTasks(userId: UUID, date: Date) async throws -> [DailyTaskItem]
    func toggleTask(id: UUID, completed: Bool) async throws
    func createTask(_ task: DailyTaskItem) async throws
}

// MARK: – Shopping

protocol ShoppingRepositoryProtocol: Sendable {
    func fetchCurrentList(userId: UUID) async throws -> ShoppingList?
    func updateList(_ list: ShoppingList) async throws
}

// MARK: – Photo Storage

protocol PhotoStorageRepositoryProtocol {
    func savePhoto(_ image: UIImage, date: Date) async throws -> ProgressPhoto
    func loadPhotos() async throws -> [ProgressPhoto]
    func deletePhoto(_ photo: ProgressPhoto) async throws
}
