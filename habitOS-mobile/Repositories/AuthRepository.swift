import Foundation
import Supabase

/// Auth repository — Supabase Auth implementation
final class AuthRepository: AuthRepositoryProtocol {
    private let client = SupabaseManager.shared.client

    func signInWithEmail(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }

    func signInWithMagicLink(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email,
            redirectTo: Config.authRedirectURL
        )
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func getCurrentSession() async throws -> UUID? {
        let session = try? await client.auth.session
        return session?.user.id
    }

    func fetchCurrentUser() async throws -> AppUser? {
        guard let authId = try await getCurrentSession() else { return nil }
        let users: [AppUser] = try await client.database
            .from("app_users")
            .select()
            .eq("auth_user_id", value: authId.uuidString)
            .limit(1)
            .execute()
            .value
        return users.first
    }
}
