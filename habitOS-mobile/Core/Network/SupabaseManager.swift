import Foundation
import Supabase

/// Singleton Supabase client manager
/// ⚠️ Uses anon key only — NEVER service_role_key
final class SupabaseManager: Sendable {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }
}
