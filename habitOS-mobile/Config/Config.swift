import Foundation

/// Configuración de habitOS — credenciales y endpoints
/// ⚠️ Solo usar anon key en cliente. NUNCA service_role_key.
enum Config {
    // MARK: – Supabase Staging
    static let supabaseURL = URL(string: "https://amhwdrduqhoekjscqzyn.supabase.co")!
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFtaHdkcmR1cWhvZWtqc2NxenluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIyMjg2NDksImV4cCI6MjA4NzgwNDY0OX0.n8j2rDo8gT6N_M_9XV7VTqvjqwxlHhfY33XUPxBmIak"

    // MARK: – App Configuration
    static let defaultWaterTargetLiters: Double = 2.5
    static let defaultStepTarget: Int = 8000
    static let defaultMealCount: Int = 5
    static let defaultTimezone: String = "Europe/Madrid"
    static let defaultLocale: String = "es"

    // MARK: – Auth
    static let authRedirectURL = URL(string: "habitos://auth-callback")!

    // MARK: – Open Food Facts API
    static let openFoodFactsBaseURL = "https://world.openfoodfacts.org/api/v2/product"
    static let openFoodFactsUserAgent = "habitOS-iOS/1.0 (contact@habitos.app)"
}
