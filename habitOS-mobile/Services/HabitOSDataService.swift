import Foundation

nonisolated enum HabitOSServiceError: Error, Sendable {
    case saveFailed
}

nonisolated final class HabitOSDataService: Sendable {
    func fetchUserProfile() async throws -> UserProfile {
        try await Task.sleep(for: .milliseconds(180))
        return UserProfile(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            email: "micael@habitos.app",
            firstName: "Micael",
            lastName: "García",
            avatarURL: nil,
            goal: "Perder grasa, ganar energía",
            currentWeightKg: 81.2,
            targetWeightKg: 78.0,
            heightCm: 168,
            coachName: "Luis da Coruña"
        )
    }

    func fetchMacroSummary() async throws -> MacroSummary {
        try await Task.sleep(for: .milliseconds(120))
        return MacroSummary(calories: 2200, protein: 165, carbs: 220, fats: 73)
    }

    func fetchMealPlan(for userID: UUID) async throws -> MealPlan {
        try await Task.sleep(for: .milliseconds(220))
        return MealPlan(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
            userID: userID,
            title: "Plan Semanal Personalizado",
            meals: [
                MealPlanEntry(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333331") ?? UUID(),
                    mealName: "🌅 Desayuno · 08:00",
                    items: ["Tortilla de claras (3)", "Pan integral (2 rebanadas)", "Aguacate (1/4)", "Café con leche desnatada"]
                ),
                MealPlanEntry(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333332") ?? UUID(),
                    mealName: "🍎 Media Mañana · 11:00",
                    items: ["Yogur griego natural", "Nueces (15g)"]
                ),
                MealPlanEntry(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
                    mealName: "🍽 Almuerzo · 13:30",
                    items: ["Pechuga a la plancha (200g)", "Arroz integral (150g)", "Ensalada mixta con AOVE"]
                ),
                MealPlanEntry(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333334") ?? UUID(),
                    mealName: "🍌 Merienda · 17:00",
                    items: ["Plátano", "Tortitas de arroz (2)"]
                ),
                MealPlanEntry(
                    id: UUID(uuidString: "33333333-3333-3333-3333-333333333335") ?? UUID(),
                    mealName: "🌙 Cena · 20:30",
                    items: ["Salmón al horno (180g)", "Camote asado", "Vegetales al vapor"]
                )
            ]
        )
    }

    func fetchHabits() async throws -> [Habit] {
        try await Task.sleep(for: .milliseconds(150))
        return [
            Habit(id: UUID(uuidString: "44444444-4444-4444-4444-444444444441") ?? UUID(), name: "Beber 2.5L de agua", isCompletedToday: true, streak: 7, completedAt: Date()),
            Habit(id: UUID(uuidString: "44444444-4444-4444-4444-444444444442") ?? UUID(), name: "8000 pasos", isCompletedToday: false, streak: 4, completedAt: nil),
            Habit(id: UUID(uuidString: "44444444-4444-4444-4444-444444444443") ?? UUID(), name: "Seguir el plan nutricional", isCompletedToday: false, streak: 11, completedAt: nil)
        ]
    }

    func fetchStreaks() async throws -> [StreakPoint] {
        try await Task.sleep(for: .milliseconds(140))
        return [
            StreakPoint(id: UUID(), dayLabel: "Lun", streakValue: 3),
            StreakPoint(id: UUID(), dayLabel: "Mar", streakValue: 4),
            StreakPoint(id: UUID(), dayLabel: "Mié", streakValue: 4),
            StreakPoint(id: UUID(), dayLabel: "Jue", streakValue: 5),
            StreakPoint(id: UUID(), dayLabel: "Vie", streakValue: 6),
            StreakPoint(id: UUID(), dayLabel: "Sáb", streakValue: 7),
            StreakPoint(id: UUID(), dayLabel: "Hoy", streakValue: 8)
        ]
    }

    func fetchDailyTasks() async throws -> [DailyTask] {
        try await Task.sleep(for: .milliseconds(100))
        return [
            DailyTask(id: UUID(), title: "Desayuno según plan", category: .nutrition, isCompleted: true, completedAt: Date()),
            DailyTask(id: UUID(), title: "Almuerzo según plan", category: .nutrition, isCompleted: false),
            DailyTask(id: UUID(), title: "2.5L de agua", category: .hydration, isCompleted: false),
            DailyTask(id: UUID(), title: "8000 pasos", category: .activity, isCompleted: false),
            DailyTask(id: UUID(), title: "Tomar omega-3", category: .supplement, isCompleted: false),
            DailyTask(id: UUID(), title: "Cenar antes de las 21:00", category: .nutrition, isCompleted: false),
        ]
    }

    func fetchWeeklySummary() async throws -> WeeklySummary {
        try await Task.sleep(for: .milliseconds(100))
        return WeeklySummary(
            adherencePercent: 78,
            currentWeightKg: 81.2,
            weightDeltaKg: -0.3,
            avgWaterLiters: 2.1,
            avgSteps: 7200
        )
    }

    func fetchNextMeal() async throws -> NextMeal {
        try await Task.sleep(for: .milliseconds(80))
        return NextMeal(
            mealName: "Almuerzo",
            timeRange: "13:30 – 14:30",
            items: ["Pechuga a la plancha", "Arroz integral (150g)", "Ensalada mixta con AOVE"]
        )
    }

    func fetchChatMessages() async throws -> [ChatMessage] {
        try await Task.sleep(for: .milliseconds(150))
        let now = Date()
        return [
            ChatMessage(id: UUID(), role: .coach, text: "¡Hola Micael! ¿Cómo te fue ayer con la cena? Vi que seguiste el plan del almuerzo 💪", timestamp: now.addingTimeInterval(-3600)),
            ChatMessage(id: UUID(), role: .user, text: "¡Bien! Seguí el plan. Pero hoy como fuera con amigos…", timestamp: now.addingTimeInterval(-3500)),
            ChatMessage(id: UUID(), role: .coach, text: "Perfecto 💪 Para comer fuera:\n• Elige proteína (carne/pescado a la plancha)\n• Evita fritos\n• Ensalada > pasta\n• Agua o infusión, nada de refrescos", timestamp: now.addingTimeInterval(-3400)),
        ]
    }

    func updateHabitCompletion(habitID: UUID, isCompleted: Bool, currentStreak: Int) async throws -> Int {
        try await Task.sleep(for: .milliseconds(250))
        let updatedStreak: Int = isCompleted ? (currentStreak + 1) : max(currentStreak - 1, 0)
        _ = habitID
        return updatedStreak
    }
}
