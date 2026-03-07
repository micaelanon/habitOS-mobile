import SwiftUI

/// Auth ViewModel — manages login, session checking, and sign-out
@Observable
final class AuthViewModel {
    var email: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var magicLinkSent: Bool = false
    var showPasswordLogin: Bool = false

    private let authRepo: AuthRepositoryProtocol

    init(authRepo: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepo = authRepo
    }

    /// Check if there's an active session
    func checkSession() async -> AppUser? {
        isLoading = true
        defer { isLoading = false }
        do {
            return try await authRepo.fetchCurrentUser()
        } catch {
            return nil
        }
    }

    /// Sign in with magic link (email-only)
    func signInWithMagicLink() async {
        guard !email.isEmpty else {
            errorMessage = "Introduce tu email"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await authRepo.signInWithMagicLink(email: email)
            magicLinkSent = true
        } catch {
            errorMessage = "Error al enviar el link: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Sign in with email + password
    func signInWithPassword() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Introduce email y contraseña"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await authRepo.signInWithEmail(email: email, password: password)
        } catch {
            errorMessage = "Credenciales incorrectas. Inténtalo de nuevo."
        }
        isLoading = false
    }

    /// Sign out
    func signOut() async {
        do {
            try await authRepo.signOut()
        } catch {
            errorMessage = "Error al cerrar sesión"
        }
    }
}
