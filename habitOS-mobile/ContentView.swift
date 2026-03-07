import SwiftUI

struct ContentView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var hasLoaded = false
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            // All tabs stay alive — hidden via opacity to prevent re-render flicker
            dashboardTab
                .opacity(selectedTab == 0 ? 1 : 0)
                .allowsHitTesting(selectedTab == 0)
            dietTab
                .opacity(selectedTab == 1 ? 1 : 0)
                .allowsHitTesting(selectedTab == 1)
            chatTab
                .opacity(selectedTab == 2 ? 1 : 0)
                .allowsHitTesting(selectedTab == 2)
            progressTab
                .opacity(selectedTab == 3 ? 1 : 0)
                .allowsHitTesting(selectedTab == 3)
            profileTab
                .opacity(selectedTab == 4 ? 1 : 0)
                .allowsHitTesting(selectedTab == 4)

            // Floating Tab Bar
            FloatingTabBar(selectedTab: $selectedTab)
        }
        .animation(nil, value: selectedTab)
        .preferredColorScheme(.light)
        .overlay {
            if viewModel.isLoading { loadingOverlay }
        }
        .task {
            guard !hasLoaded else { return }
            hasLoaded = true
            await viewModel.loadDashboard()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: – Tab 1: Hoy
    private var dashboardTab: some View {
        NavigationStack {
            DashboardHomeView(
                user: viewModel.user,
                macroSummary: viewModel.macroSummary,
                dailyTasks: viewModel.dailyTasks,
                dailyProgress: viewModel.dailyProgress,
                completedCount: viewModel.completedTasksCount,
                totalCount: viewModel.totalTasksCount,
                nextMeal: viewModel.nextMeal,
                weeklySummary: viewModel.weeklySummary,
                lastCoachMessage: viewModel.lastCoachMessage,
                waterLiters: viewModel.waterLiters,
                waterTarget: viewModel.waterTarget,
                onToggleTask: { viewModel.toggleDailyTask($0) },
                onAddWater: { viewModel.addWater($0) }
            )
            .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
        }
    }

    // MARK: – Tab 2: Dieta
    private var dietTab: some View {
        NavigationStack {
            MealPlanView(mealPlan: viewModel.mealPlan, macroSummary: viewModel.macroSummary)
                .navigationTitle("Dieta")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
        }
    }

    // MARK: – Tab 3: Chat
    private var chatTab: some View {
        NavigationStack {
            ChatView(
                messages: viewModel.chatMessages,
                coachName: viewModel.user?.coachName ?? "Coach"
            )
            .navigationTitle(viewModel.user?.coachName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hbPaper.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: {
                        Image(systemName: "video")
                            .foregroundStyle(Color.hbSage)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
        }
    }

    // MARK: – Tab 4: Progreso
    private var progressTab: some View {
        NavigationStack {
            ProgressChartView(
                streaks: viewModel.streaks,
                weeklySummary: viewModel.weeklySummary
            )
            .navigationTitle("Progreso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
        }
    }

    // MARK: – Tab 5: Perfil
    private var profileTab: some View {
        NavigationStack {
            ProfileView(user: viewModel.user)
                .navigationTitle("Perfil")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
        }
    }

    // MARK: – Loading Overlay
    private var loadingOverlay: some View {
        ZStack {
            Color.hbVanilla.opacity(0.97)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .stroke(Color.hbLine, lineWidth: 2.5)
                        .frame(width: 52, height: 52)
                    Circle()
                        .trim(from: 0, to: 0.3)
                        .stroke(Color.hbSage, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(loadingRotation))
                        .onAppear {
                            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                                loadingRotation = 360
                            }
                        }
                }

                VStack(spacing: 8) {
                    HBLogoView(size: 22)
                    Text("Preparando tu plan…")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hbMuted)
                }
            }
        }
    }

    @State private var loadingRotation: Double = 0
}

#Preview {
    ContentView()
}
