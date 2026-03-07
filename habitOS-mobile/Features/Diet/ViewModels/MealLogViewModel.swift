import Foundation
import Observation

@Observable
final class MealLogViewModel {
    var actualDescription: String = ""
    var followedPlan: Bool = true
    var deviationReason: String = ""
    var photoData: Data?
    
    var isSaving = false
    var isSaved = false
    var errorMessage: String?
    
    func saveLog(mealType: String, planItems: [String]) async {
        isSaving = true
        defer { isSaving = false }
        
        // Simulating the network upload to Supabase `meal_logs` table
        // In the real implementation, this would insert a `MealLog` struct via the Supabase client
        do {
            try await Task.sleep(nanoseconds: 800_000_000) // 0.8s
            await MainActor.run { isSaved = true }
        } catch {
            await MainActor.run { errorMessage = error.localizedDescription }
        }
    }
}
