import Foundation
import UserNotifications

/// Manages all local notifications for habitOS
/// Types: morning greeting, meal reminders, water reminders, journal prompt, weekly weight
final class NotificationManager {
    static let shared = NotificationManager()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: – Permission

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    // MARK: – Schedule All

    /// Call this after login and after any preference change
    func scheduleAll(userName: String, mealTimes: [(name: String, time: String)]?) async {
        // Clear existing
        center.removeAllPendingNotificationRequests()

        scheduleMorningGreeting(userName: userName)
        scheduleJournalReminder()
        scheduleWeeklyWeightReminder()
        scheduleWaterReminders()

        if let meals = mealTimes {
            for meal in meals {
                scheduleMealReminder(mealName: meal.name, time: meal.time)
            }
        }
    }

    // MARK: – Morning Greeting (08:00 daily)

    private func scheduleMorningGreeting(userName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Buenos días, \(userName) 👋"
        content.body = "Revisa tus objetivos de hoy y empieza con buen pie."
        content.sound = .default
        content.categoryIdentifier = "MORNING"

        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "morning-greeting", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: – Meal Reminder (15 min before each meal)

    private func scheduleMealReminder(mealName: String, time: String) {
        guard let (hour, minute) = parseTime(time) else { return }

        let content = UNMutableNotificationContent()
        content.title = "🍽 Hora de \(mealName.lowercased())"
        content.body = "Tu \(mealName.lowercased()) está planificado. ¡A por ello!"
        content.sound = .default
        content.categoryIdentifier = "MEAL"

        // 15 minutes before
        var adjustedMinute = minute - 15
        var adjustedHour = hour
        if adjustedMinute < 0 {
            adjustedMinute += 60
            adjustedHour -= 1
        }

        var dateComponents = DateComponents()
        dateComponents.hour = adjustedHour
        dateComponents.minute = adjustedMinute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let id = "meal-\(mealName.lowercased().replacingOccurrences(of: " ", with: "-"))"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: – Water Reminders (every 2h between 09:00-21:00)

    private func scheduleWaterReminders() {
        let hours = stride(from: 9, to: 22, by: 2)
        for hour in hours {
            let content = UNMutableNotificationContent()
            content.title = "💧 ¿Has bebido agua?"
            content.body = "Recuerda mantenerte hidratado. Cada vaso cuenta."
            content.sound = .default
            content.categoryIdentifier = "WATER"

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(identifier: "water-\(hour)", content: content, trigger: trigger)
            center.add(request)
        }
    }

    // MARK: – Journal Reminder (21:00 daily)

    private func scheduleJournalReminder() {
        let content = UNMutableNotificationContent()
        content.title = "📝 ¿Cómo fue tu día?"
        content.body = "Cuéntale a tu diario cómo te ha ido hoy. Es rápido y te ayuda."
        content.sound = .default
        content.categoryIdentifier = "JOURNAL"

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "journal-reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: – Weekly Weight Reminder (Monday 08:00)

    private func scheduleWeeklyWeightReminder() {
        let content = UNMutableNotificationContent()
        content.title = "⚖️ ¿Te pesas hoy?"
        content.body = "Es lunes. Registra tu peso para ver tu progreso semanal."
        content.sound = .default
        content.categoryIdentifier = "WEIGHT"

        var dateComponents = DateComponents()
        dateComponents.weekday = 2 // Monday
        dateComponents.hour = 8
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly-weight", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: – Helpers

    private func parseTime(_ time: String) -> (hour: Int, minute: Int)? {
        let parts = time.split(separator: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return nil }
        return (hour, minute)
    }

    /// Cancel all
    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }
}
