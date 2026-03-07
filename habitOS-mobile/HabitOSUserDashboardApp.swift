import SwiftUI

@main
struct HabitOSUserDashboardApp: App {
    @State private var appState = AppState()
    @State private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    // Splash / session check
                    splashView
                } else if !appState.isAuthenticated {
                    // Not logged in
                    LoginView { user in
                        appState.currentUser = user
                        appState.isAuthenticated = true
                        if !user.onboardingCompleted {
                            appState.showOnboarding = true
                        }
                    }
                    .transition(.opacity)
                } else if appState.showOnboarding {
                    // First time onboarding
                    OnboardingView {
                        appState.showOnboarding = false
                    }
                    .transition(.opacity)
                } else {
                    // Main app
                    ContentView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: appState.showOnboarding)
            .task {
                await checkSession()
            }
        }
    }

    private func checkSession() async {
        // Give the splash a moment to show
        try? await Task.sleep(for: .milliseconds(800))

        if let user = await authViewModel.checkSession() {
            appState.currentUser = user
            appState.isAuthenticated = true
        }
        appState.isLoading = false
    }

    private var splashView: some View {
        ZStack {
            Color.hbVanilla.ignoresSafeArea()
            VStack(spacing: 20) {
                HBLogoView(size: 44)
                Text("habitOS")
                    .font(.custom("Georgia", size: 32, relativeTo: .largeTitle))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.hbInk)
                ProgressView()
                    .tint(Color.hbSage)
            }
        }
    }
}
