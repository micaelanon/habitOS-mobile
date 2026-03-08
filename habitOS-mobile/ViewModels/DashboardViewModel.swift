import Foundation
import Observation
import Supabase

@Observable
@MainActor
final class DashboardViewModel {
    // MARK: – Published State (real types)
    var user: AppUser?
    var coachName: String = "Tu nutricionista"
    var macroSummary: MacroSummary?
    var activePlan: NutritionPlan?
    var habits: [Habit] = []
    var streaks: [StreakPoint] = []
    var dailyTasks: [DailyTaskItem] = []
    var weeklySummary: WeeklySummary?
    var nextMeal: NextMeal?
    var chatMessages: [CoachMessage] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var waterLiters: Double = 0.0
    var waterTarget: Double = 2.5

    let health = HealthKitManager.shared

    // MARK: – Dependencies
    private let authRepo: AuthRepositoryProtocol
    private let dietRepo: DietRepositoryProtocol
    private let taskRepo: TaskRepositoryProtocol
    private let chatRepo: ChatRepositoryProtocol
    private let journalRepo: JournalRepositoryProtocol

    init(
        authRepo: AuthRepositoryProtocol = AuthRepository(),
        dietRepo: DietRepositoryProtocol = DietRepository(),
        taskRepo: TaskRepositoryProtocol = TaskRepository(),
        chatRepo: ChatRepositoryProtocol = ChatRepository(),
        journalRepo: JournalRepositoryProtocol = JournalRepository()
    ) {
        self.authRepo = authRepo
        self.dietRepo = dietRepo
        self.taskRepo = taskRepo
        self.chatRepo = chatRepo
        self.journalRepo = journalRepo
    }

    // MARK: – Computed
    var dailyProgress: Double {
        guard !dailyTasks.isEmpty else { return 0 }
        let completed = dailyTasks.filter(\.isCompleted).count
        return Double(completed) / Double(dailyTasks.count)
    }

    var completedTasksCount: Int { dailyTasks.filter(\.isCompleted).count }
    var totalTasksCount: Int { dailyTasks.count }

    var accountMode: AccountMode {
        user?.accountMode ?? .soloAI
    }

    var advisorDisplayName: String {
        switch accountMode {
        case .soloAI, .hybridTransition: return "habitOS"
        case .coachConnected: return coachName
        }
    }

    var lastCoachMessage: CoachMessage? {
        chatMessages.last(where: { $0.role == .assistant })
    }

    /// Today's meals derived from the active nutrition plan.
    var todayMeals: DayMeals? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return activePlan?.mealPlan.meals(for: weekday)
    }

    // MARK: – Load

    /// Main entry point. Pass the authenticated user, or nil if the user
    /// explicitly chose demo mode (appState.isDemo should also be true).
    func loadDashboard(user: AppUser?, isDemo: Bool = false) async {
        isLoading = true
        errorMessage = nil

        guard let user = user else {
            if isDemo {
                print("[HabitOS] Loading demo dashboard (explicit demo mode)")
            } else {
                print("[HabitOS] Warning: loadDashboard called with nil user outside demo mode")
            }
            await loadDemo()
            isLoading = false
            return
        }

        self.user = user

        do {
            // Coach name from coach_profiles
            if let cpId = user.coachProfileId {
                await loadCoachName(cpId)
            }

            // Fetch active nutrition plan → macros + next meal
            let plan = try await dietRepo.fetchActivePlan(userId: user.id)
            activePlan = plan
            if let plan {
                macroSummary = MacroSummary(
                    calories: plan.dailyCalories ?? 0,
                    protein: plan.dailyProteinG ?? 0,
                    carbs: plan.dailyCarbsG ?? 0,
                    fats: plan.dailyFatsG ?? 0
                )
                nextMeal = computeNextMeal(from: plan)
            }

            // Daily tasks
            dailyTasks = try await taskRepo.fetchTasks(userId: user.id, date: Date())

            // Journal → water
            if let journal = try? await journalRepo.fetchEntry(userId: user.id, date: Date()) {
                waterLiters = journal.waterLiters ?? 0
            }

            // Chat — last few messages for dashboard card
            chatMessages = try await chatRepo.fetchMessages(profileId: user.id, limit: 10)

            // Streaks + weekly summary: computed locally until dedicated endpoints exist
            loadSummaryPlaceholders()

            // HealthKit
            if health.isAuthorized {
                await health.fetchAllData()
            }

            // Notifications
            let isAuthorized = await NotificationManager.shared.requestPermission()
            if isAuthorized {
                await NotificationManager.shared.scheduleAll(
                    userName: user.firstName,
                    mealTimes: nil
                )
            }
        } catch {
            print("[HabitOS] Dashboard load error (falling back to demo): \(error.localizedDescription)")
            await loadDemo()
            // Fallback succeeded — don't surface an error alert to the user
        }
        isLoading = false
    }

    // MARK: – Actions

    func toggleDailyTask(_ task: DailyTaskItem) {
        guard let index = dailyTasks.firstIndex(where: { $0.id == task.id }) else { return }
        let newState = !dailyTasks[index].isCompleted
        dailyTasks[index].isCompleted = newState
        dailyTasks[index].completedAt = newState ? Date() : nil

        Task {
            do {
                try await taskRepo.toggleTask(id: task.id, completed: newState)
            } catch {
                // Revert on failure
                if let i = dailyTasks.firstIndex(where: { $0.id == task.id }) {
                    dailyTasks[i].isCompleted = !newState
                    dailyTasks[i].completedAt = !newState ? Date() : nil
                }
                errorMessage = "No se pudo actualizar la tarea."
            }
        }
    }

    func addWater(_ liters: Double) {
        withMutation(keyPath: \.waterLiters) {
            waterLiters = min(waterLiters + liters, waterTarget)
        }
    }

    // MARK: – Private Helpers

    private func loadCoachName(_ coachProfileId: UUID) async {
        struct CoachRow: Decodable {
            let coachName: String
            enum CodingKeys: String, CodingKey { case coachName = "coach_name" }
        }
        do {
            let rows: [CoachRow] = try await SupabaseManager.shared.client.database
                .from("coach_profiles")
                .select("coach_name")
                .eq("id", value: coachProfileId.uuidString)
                .limit(1)
                .execute()
                .value
            if let row = rows.first {
                coachName = row.coachName
            }
        } catch {
            // Silently keep default "Coach"
        }
    }

    private func computeNextMeal(from plan: NutritionPlan) -> NextMeal? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        guard let dayMeals = plan.mealPlan.meals(for: weekday) else { return nil }

        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        let nowStr = fmt.string(from: Date())

        // Walk through meals in order, return the first one whose time is >= now
        for (type, meal) in dayMeals.allMeals {
            if let t = meal.time, t >= nowStr {
                return NextMeal(
                    mealName: type,
                    timeRange: t,
                    items: meal.ingredients?.map(\.displayText) ?? [meal.name]
                )
            }
        }
        // If all meals passed, return nil
        return nil
    }

    /// Placeholder streak + weekly data until dedicated aggregation endpoints exist.
    private func loadSummaryPlaceholders() {
        let dayLabels = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Hoy"]
        streaks = dayLabels.enumerated().map { i, label in
            StreakPoint(id: UUID(), dayLabel: label, streakValue: min(i + 3, 8))
        }
        weeklySummary = WeeklySummary(
            adherencePercent: dailyTasks.isEmpty ? 0 : Int(dailyProgress * 100),
            currentWeightKg: user?.currentWeightKg ?? 0,
            weightDeltaKg: 0,
            avgWaterLiters: waterLiters,
            avgSteps: health.dailySteps > 0 ? health.dailySteps : 0
        )
    }

    // MARK: – Demo Fallback

    private func loadDemo() async {
        // Preserve user from AppState if already set (chosen at login screen)
        if user == nil {
            let fallbackId = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!
            user = AppUser(
                id: fallbackId,
                authUserId: fallbackId,
                coachProfileId: nil,
                firstName: "Micael",
                lastName: "García",
                email: "micael@habitos.app",
                phone: nil,
                avatarUrl: nil,
                sex: "male",
                dateOfBirth: nil,
                heightCm: 168,
                currentWeightKg: 81.2,
                goal: "Perder grasa, ganar energía",
                activityLevel: "moderate",
                foodAllergies: [],
                foodDislikes: [],
                dietType: nil,
                medicalConditions: [],
                timezone: "Europe/Madrid",
                locale: "es",
                notificationsEnabled: true,
                healthkitEnabled: false,
                onboardingCompleted: true,
                createdAt: Date(),
                updatedAt: Date()
            )
        }

        // Coach name follows account mode
        if accountMode == .coachConnected {
            coachName = "Luis da Coruña"
        }

        let demoId = user!.id

        activePlan = NutritionPlan.demoPlan(userId: demoId)
        macroSummary = MacroSummary(calories: 2200, protein: 165, carbs: 220, fats: 73)

        let today = Date()
        dailyTasks = [
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "Desayuno según plan", category: "nutrition", isCompleted: true, completedAt: today, sortOrder: 0, autoGenerated: true, source: "plan", createdAt: today),
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "Almuerzo según plan", category: "nutrition", isCompleted: false, completedAt: nil, sortOrder: 1, autoGenerated: true, source: "plan", createdAt: today),
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "2.5L de agua", category: "hydration", isCompleted: false, completedAt: nil, sortOrder: 2, autoGenerated: true, source: "plan", createdAt: today),
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "8000 pasos", category: "activity", isCompleted: false, completedAt: nil, sortOrder: 3, autoGenerated: true, source: "plan", createdAt: today),
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "Tomar omega-3", category: "supplement", isCompleted: false, completedAt: nil, sortOrder: 4, autoGenerated: true, source: "plan", createdAt: today),
            DailyTaskItem(id: UUID(), userId: demoId, taskDate: today, title: "Cenar antes de las 21:00", category: "nutrition", isCompleted: false, completedAt: nil, sortOrder: 5, autoGenerated: true, source: "plan", createdAt: today),
        ]

        waterLiters = 1.5

        let now = Date()
        chatMessages = [
            CoachMessage(id: UUID(), profileId: demoId, role: .assistant, channel: "app", messageText: "¡Hola Micael! ¿Cómo te fue ayer con la cena? Vi que seguiste el plan del almuerzo 💪", mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil, createdAt: now.addingTimeInterval(-3600)),
            CoachMessage(id: UUID(), profileId: demoId, role: .user, channel: "app", messageText: "¡Bien! Seguí el plan. Pero hoy como fuera con amigos…", mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil, createdAt: now.addingTimeInterval(-3500)),
            CoachMessage(id: UUID(), profileId: demoId, role: .assistant, channel: "app", messageText: "Perfecto 💪 Para comer fuera:\n• Elige proteína (carne/pescado a la plancha)\n• Evita fritos\n• Ensalada > pasta\n• Agua o infusión, nada de refrescos", mediaType: nil, mediaUrl: nil, metadata: nil, expiresAt: nil, createdAt: now.addingTimeInterval(-3400)),
        ]

        streaks = [
            StreakPoint(id: UUID(), dayLabel: "Lun", streakValue: 3),
            StreakPoint(id: UUID(), dayLabel: "Mar", streakValue: 4),
            StreakPoint(id: UUID(), dayLabel: "Mié", streakValue: 4),
            StreakPoint(id: UUID(), dayLabel: "Jue", streakValue: 5),
            StreakPoint(id: UUID(), dayLabel: "Vie", streakValue: 6),
            StreakPoint(id: UUID(), dayLabel: "Sáb", streakValue: 7),
            StreakPoint(id: UUID(), dayLabel: "Hoy", streakValue: 8),
        ]

        weeklySummary = WeeklySummary(
            adherencePercent: 78,
            currentWeightKg: 81.2,
            weightDeltaKg: -0.3,
            avgWaterLiters: 2.1,
            avgSteps: 7200
        )

        nextMeal = NextMeal(
            mealName: "Almuerzo",
            timeRange: "13:30 – 14:30",
            items: ["Pechuga a la plancha", "Arroz integral (150g)", "Ensalada mixta con AOVE"]
        )

        habits = [
            Habit(id: UUID(), name: "Beber 2.5L de agua", isCompletedToday: true, streak: 7, completedAt: Date()),
            Habit(id: UUID(), name: "8000 pasos", isCompletedToday: false, streak: 4, completedAt: nil),
            Habit(id: UUID(), name: "Seguir el plan nutricional", isCompletedToday: false, streak: 11, completedAt: nil),
        ]
    }
}
