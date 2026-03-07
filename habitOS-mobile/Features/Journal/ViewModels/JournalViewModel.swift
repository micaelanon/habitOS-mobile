import SwiftUI

/// Journal ViewModel — manages the daily check-in data
@Observable
final class JournalViewModel {
    var selectedDate: Date = Date()
    var mood: String? = nil
    var energyLevel: Int? = nil
    var sleepHours: Double = 7.0
    var sleepQuality: String? = nil
    var waterLiters: Double = 0.0
    var steps: Int = 0
    var trainingDone: Bool = false
    var trainingNotes: String = ""
    var mealsFollowed: Int = 0
    var mealsTotal: Int = 5
    var cravings: String = ""
    var symptoms: String = ""
    var freeText: String = ""
    var highlight: String = ""
    var isLoading: Bool = false
    var isSaved: Bool = false
    var errorMessage: String?

    private let repository: JournalRepositoryProtocol
    private var currentEntry: JournalEntry?
    private var userId: UUID?

    init(repository: JournalRepositoryProtocol = JournalRepository()) {
        self.repository = repository
    }

    func loadEntry(userId: UUID) async {
        self.userId = userId
        isLoading = true
        defer { isLoading = false }
        do {
            if let entry = try await repository.fetchEntry(userId: userId, date: selectedDate) {
                currentEntry = entry
                mood = entry.mood
                energyLevel = entry.energyLevel
                sleepHours = entry.sleepHours ?? 7.0
                sleepQuality = entry.sleepQuality
                waterLiters = entry.waterLiters ?? 0.0
                steps = entry.steps ?? 0
                trainingDone = entry.trainingDone
                trainingNotes = entry.trainingNotes ?? ""
                mealsFollowed = entry.mealsFollowed ?? 0
                mealsTotal = entry.mealsTotal ?? 5
                cravings = entry.cravings ?? ""
                symptoms = entry.symptoms ?? ""
                freeText = entry.freeText ?? ""
                highlight = entry.highlight ?? ""
            }
        } catch {
            errorMessage = "Error al cargar el diario"
        }
    }

    func saveEntry() async {
        guard let userId = userId else { return }
        isLoading = true
        defer { isLoading = false }

        let entry = JournalEntry(
            id: currentEntry?.id ?? UUID(),
            userId: userId,
            entryDate: selectedDate,
            mood: mood,
            energyLevel: energyLevel,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            waterLiters: waterLiters,
            steps: steps,
            trainingDone: trainingDone,
            trainingNotes: trainingNotes.isEmpty ? nil : trainingNotes,
            mealsFollowed: mealsFollowed,
            mealsTotal: mealsTotal,
            cravings: cravings.isEmpty ? nil : cravings,
            symptoms: symptoms.isEmpty ? nil : symptoms,
            freeText: freeText.isEmpty ? nil : freeText,
            highlight: highlight.isEmpty ? nil : highlight,
            tags: [],
            createdAt: currentEntry?.createdAt ?? Date(),
            updatedAt: Date()
        )

        do {
            try await repository.saveEntry(entry)
            currentEntry = entry
            isSaved = true

            // Reset after 2 seconds
            try? await Task.sleep(for: .seconds(2))
            isSaved = false
        } catch {
            errorMessage = "Error al guardar el diario"
        }
    }

    func addWater(_ amount: Double) {
        waterLiters += amount
    }
}
