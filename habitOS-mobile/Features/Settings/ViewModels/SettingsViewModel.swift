import SwiftUI

/// Manages user preferences and settings actions
@Observable
final class SettingsViewModel {
    var isNotificationsEnabled: Bool = true
    var isHealthKitEnabled: Bool = false
    var selectedLanguage: String = "Español"
    var selectedUnit: String = "Métrico (kg, cm)"

    var showLogoutConfirm = false
    var isAttemptingLogout = false

    func logout(appState: AppState) async {
        isAttemptingLogout = true
        defer { isAttemptingLogout = false }

        do {
            try await AuthRepository().signOut()
            // Reset AppState to bump back to authentication screen
            await MainActor.run {
                appState.signOut()
            }
        } catch {
            print("Error logging out: \(error)")
        }
    }
}
