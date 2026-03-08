import Foundation

// DEPRECATED: HabitOSDataService was the original mock data provider.
// DashboardViewModel now uses real repositories (Auth, Diet, Task, Chat, Journal)
// with an inline demo fallback via loadDemo().
// This file is kept temporarily to avoid Xcode project file issues.
// Remove this file and its Xcode reference once compilation is verified.

nonisolated enum HabitOSServiceError: Error, Sendable {
    case saveFailed
}
