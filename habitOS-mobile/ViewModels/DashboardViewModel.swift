import Foundation
import Observation

@Observable
@MainActor
final class DashboardViewModel {
    var user: UserProfile?
    var macroSummary: MacroSummary?
    var mealPlan: MealPlan?
    var habits: [Habit] = []
    var streaks: [StreakPoint] = []
    var dailyTasks: [DailyTask] = []
    var weeklySummary: WeeklySummary?
    var nextMeal: NextMeal?
    var chatMessages: [ChatMessage] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var waterLiters: Double = 1.5
    var waterTarget: Double = 2.5
    
    let health = HealthKitManager.shared

    private let service: HabitOSDataService

    init(service: HabitOSDataService = HabitOSDataService()) {
        self.service = service
    }

    // MARK: Computed
    var dailyProgress: Double {
        guard !dailyTasks.isEmpty else { return 0 }
        let completed = dailyTasks.filter(\.isCompleted).count
        return Double(completed) / Double(dailyTasks.count)
    }

    var completedTasksCount: Int { dailyTasks.filter(\.isCompleted).count }
    var totalTasksCount: Int { dailyTasks.count }

    var lastCoachMessage: ChatMessage? {
        chatMessages.last(where: { $0.role == .coach })
    }

    // MARK: Load
    func loadDashboard() async {
        isLoading = true
        errorMessage = nil
        do {
            async let profileTask = service.fetchUserProfile()
            async let macrosTask = service.fetchMacroSummary()
            async let habitsTask = service.fetchHabits()
            async let streakTask = service.fetchStreaks()
            async let tasksTask = service.fetchDailyTasks()
            async let summaryTask = service.fetchWeeklySummary()
            async let mealTask = service.fetchNextMeal()
            async let messagesTask = service.fetchChatMessages()

            let profile = try await profileTask
            let macros = try await macrosTask
            let plan = try await service.fetchMealPlan(for: profile.id)
            let userHabits = try await habitsTask
            let streakData = try await streakTask
            let tasks = try await tasksTask
            let summary = try await summaryTask
            let meal = try await mealTask
            let messages = try await messagesTask

            user = profile
            macroSummary = macros
            mealPlan = plan
            habits = userHabits
            streaks = streakData
            dailyTasks = tasks
            weeklySummary = summary
            nextMeal = meal
            chatMessages = messages
            
            if health.isAuthorized {
                await health.fetchAllData()
            }
            
            let isAuthorized = await NotificationManager.shared.requestPermission()
            if isAuthorized {
                // Pass nil for meal times for now as a fallback, or we can parse `mealPlan`
                let parsedMeals = mealPlan?.meals.map { (name: $0.mealName, time: "14:00") }
                await NotificationManager.shared.scheduleAll(
                    userName: user?.firstName ?? "HabitOS",
                    mealTimes: parsedMeals
                )
            }
        } catch {
            errorMessage = "No pudimos cargar tu dashboard. Intenta nuevamente."
        }
        isLoading = false
    }

    // MARK: Actions
    func toggleHabit(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        let oldHabit = habits[index]
        let newState = !oldHabit.isCompletedToday

        habits[index].isCompletedToday = newState
        habits[index].completedAt = newState ? Date() : nil
        habits[index].streak = newState ? (oldHabit.streak + 1) : max(oldHabit.streak - 1, 0)

        Task {
            do {
                let serverStreak = try await service.updateHabitCompletion(
                    habitID: oldHabit.id, isCompleted: newState, currentStreak: oldHabit.streak
                )
                guard let i = habits.firstIndex(where: { $0.id == oldHabit.id }) else { return }
                habits[i].streak = serverStreak
            } catch {
                guard let i = habits.firstIndex(where: { $0.id == oldHabit.id }) else { return }
                habits[i] = oldHabit
                errorMessage = "No se pudo guardar el hábito."
            }
        }
    }

    func toggleDailyTask(_ task: DailyTask) {
        guard let index = dailyTasks.firstIndex(where: { $0.id == task.id }) else { return }
        dailyTasks[index].isCompleted.toggle()
        dailyTasks[index].completedAt = dailyTasks[index].isCompleted ? Date() : nil
    }

    func addWater(_ liters: Double) {
        withMutation(keyPath: \.waterLiters) {
            waterLiters = min(waterLiters + liters, waterTarget)
        }
    }
}
