import SwiftUI

/// Weight Tracking ViewModel
@Observable
final class TrackingViewModel {
    var weightLogs: [WeightLog] = []
    var isLoading: Bool = false
    var showingEntrySheet: Bool = false
    var errorMessage: String?
    var savedConfirmation: Bool = false

    // Entry form
    var newWeight: String = ""
    var newBodyFat: String = ""
    var newNotes: String = ""

    // User stats
    var startWeight: Double?
    var goalWeight: Double?

    private let repository: TrackingRepositoryProtocol
    private var userId: UUID?

    init(repository: TrackingRepositoryProtocol = TrackingRepository()) {
        self.repository = repository
    }

    var currentWeight: Double? { weightLogs.first?.weightKg }

    var weightProgress: Double? {
        guard let start = startWeight, let goal = goalWeight, let current = currentWeight else { return nil }
        let totalToLose = start - goal
        guard totalToLose > 0 else { return nil }
        let lost = start - current
        return min(max(lost / totalToLose, 0), 1.0)
    }

    var lastDelta: Double? {
        guard weightLogs.count >= 2 else { return nil }
        return weightLogs[0].weightKg - weightLogs[1].weightKg
    }

    func loadLogs(userId: UUID, startWeight: Double?, goalWeight: Double?) async {
        self.userId = userId
        self.startWeight = startWeight
        self.goalWeight = goalWeight
        isLoading = true
        defer { isLoading = false }
        do {
            weightLogs = try await repository.fetchWeightLogs(userId: userId, limit: 90)
        } catch {
            errorMessage = "Error al cargar registros de peso"
        }
    }

    func saveWeight() async {
        guard let userId = userId,
              let weight = Double(newWeight.replacingOccurrences(of: ",", with: ".")) else {
            errorMessage = "Introduce un peso válido"
            return
        }
        isLoading = true
        defer { isLoading = false }
        let log = WeightLog(
            id: UUID(),
            userId: userId,
            weightKg: weight,
            bodyFatPct: Double(newBodyFat.replacingOccurrences(of: ",", with: ".")),
            muscleMassKg: nil,
            waistCm: nil,
            hipCm: nil,
            notes: newNotes.isEmpty ? nil : newNotes,
            source: "manual",
            loggedAt: Date(),
            createdAt: Date()
        )
        do {
            try await repository.logWeight(log)
            weightLogs.insert(log, at: 0)
            showingEntrySheet = false
            newWeight = ""
            newBodyFat = ""
            newNotes = ""
            savedConfirmation = true
            try? await Task.sleep(for: .seconds(2))
            savedConfirmation = false
        } catch {
            errorMessage = "Error al guardar el peso"
        }
    }
}
