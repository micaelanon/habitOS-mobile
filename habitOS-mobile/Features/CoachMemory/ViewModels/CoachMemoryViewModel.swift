import Foundation
import Supabase


@Observable
final class CoachMemoryViewModel {
    var memories: [CoachMemory] = []
    var isLoading = false
    var errorMessage: String?

    // Demo data so the view looks great even without Supabase data
    var groupedMemories: [(category: String, icon: String, items: [CoachMemory])] {
        let categoryMeta: [(key: String, icon: String)] = [
            ("Cuerpo", "figure.wave"),
            ("Preferencias", "heart"),
            ("Historial", "clock.arrow.circlepath"),
            ("Objetivos", "target"),
            ("Hábitos", "sparkles"),
        ]
        return categoryMeta.compactMap { meta in
            let items = memories.filter { $0.category == meta.key }
            return items.isEmpty ? nil : (meta.key, meta.icon, items)
        }
    }

    func load(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }

        // Try Supabase; fall back to demo data gracefully
        do {
            let fetched: [CoachMemory] = try await SupabaseManager.shared.client
                .from("coach_memories")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            await MainActor.run { memories = fetched }
        } catch {
            // Use demo data if table doesn't exist yet or user has no memories
            await MainActor.run { memories = Self.demo }
        }
    }

    func forget(memory: CoachMemory) {
        memories.removeAll { $0.id == memory.id }
    }

    // MARK: – Demo data
    static let demo: [CoachMemory] = [
        CoachMemory(id: UUID(), userId: UUID(), category: "Cuerpo",
                    fact: "Peso actual: 78 kg", createdAt: Date()),
        CoachMemory(id: UUID(), userId: UUID(), category: "Cuerpo",
                    fact: "Altura: 180 cm", createdAt: Date().addingTimeInterval(-86400 * 2)),
        CoachMemory(id: UUID(), userId: UUID(), category: "Objetivos",
                    fact: "Meta: perder 5 kg para verano", createdAt: Date().addingTimeInterval(-86400 * 5)),
        CoachMemory(id: UUID(), userId: UUID(), category: "Preferencias",
                    fact: "No le gusta el brócoli crudo", createdAt: Date().addingTimeInterval(-86400)),
        CoachMemory(id: UUID(), userId: UUID(), category: "Preferencias",
                    fact: "Prefiere desayunos ligeros", createdAt: Date().addingTimeInterval(-86400 * 3)),
        CoachMemory(id: UUID(), userId: UUID(), category: "Hábitos",
                    fact: "Hace 3 entrenos por semana", createdAt: Date().addingTimeInterval(-86400 * 7)),
        CoachMemory(id: UUID(), userId: UUID(), category: "Historial",
                    fact: "Empezó el programa el 1 de enero", createdAt: Date().addingTimeInterval(-86400 * 65)),
    ]
}
