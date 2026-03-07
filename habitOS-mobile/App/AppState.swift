import SwiftUI

/// Global app state — observable across the entire app
@Observable
final class AppState {
    // MARK: – Auth
    var isAuthenticated: Bool = false
    var currentUserId: UUID?
    var currentUser: AppUser?

    // MARK: – Navigation
    var selectedTab: Int = 0
    var showOnboarding: Bool = false

    // MARK: – Loading
    var isLoading: Bool = true
    var errorMessage: String?

    // MARK: – Methods
    func signOut() {
        isAuthenticated = false
        currentUserId = nil
        currentUser = nil
        selectedTab = 0
    }
}
