import SwiftUI

struct ContentView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var hasLoaded = false
    @State private var selectedTab = 0

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.hbVanilla)
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor(Color.hbSage)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(Color.hbSage)]
        
        itemAppearance.normal.iconColor = UIColor(Color.hbMuted)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.hbMuted)]
        
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            dashboardTab
                .tabItem {
                    Label("Hoy", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            dietTab
                .tabItem {
                    Label("Dieta", systemImage: selectedTab == 1 ? "leaf.fill" : "leaf")
                }
                .tag(1)

            chatTab
                .tabItem {
                    Label("Chat", systemImage: selectedTab == 2 ? "message.fill" : "message")
                }
                .tag(2)

            progressTab
                .tabItem {
                    Label("Progreso", systemImage: selectedTab == 3 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            profileTab
                .tabItem {
                    Label("Perfil", systemImage: selectedTab == 4 ? "person.crop.circle.fill" : "person.crop.circle")
                }
                .tag(4)
        }
        .tint(Color.hbSage)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: ProgressPhotosView()) {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(Color.hbSage)
                    }
                }
            }
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
