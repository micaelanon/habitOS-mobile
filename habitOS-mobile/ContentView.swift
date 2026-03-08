import SwiftUI

struct ContentView: View {
    @State private var viewModel = DashboardViewModel()
    @State private var hasLoaded = false
    @State private var selectedTab = 0
    @State private var showVideoCall = false

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
            if viewModel.isLoading { AppLoadingOverlay() }
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
                health: viewModel.health,
                onToggleTask: { viewModel.toggleDailyTask($0) },
                onAddWater: { viewModel.addWater($0) },
                onGoToChat: { selectedTab = 2 },
                onGoToDiet: { selectedTab = 1 }
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
                coachName: viewModel.user?.coachName ?? "Coach",
                onSend: { text in
                    // Add user message
                    let userMsg = ChatMessage(id: UUID(), role: .user, text: text, timestamp: Date())
                    viewModel.chatMessages.append(userMsg)
                    // Demo auto-reply
                    Task {
                        try? await Task.sleep(for: .milliseconds(1200))
                        let reply = ChatMessage(
                            id: UUID(), role: .coach,
                            text: demoReply(for: text),
                            timestamp: Date()
                        )
                        viewModel.chatMessages.append(reply)
                    }
                }
            )
            .navigationTitle(viewModel.user?.coachName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.hbPaper.opacity(0.95), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showVideoCall = true } label: {
                        Image(systemName: "video")
                            .foregroundStyle(Color.hbSage)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) { Spacer().frame(height: 90) }
            .fullScreenCover(isPresented: $showVideoCall) {
                VideoCallView(coachName: viewModel.user?.coachName ?? "Coach")
            }
        }
    }

    // MARK: – Tab 4: Progreso
    private var progressTab: some View {
        NavigationStack {
            ProgressChartView(
                streaks: viewModel.streaks,
                weeklySummary: viewModel.weeklySummary,
                userId: viewModel.user?.id,
                startWeight: viewModel.user?.currentWeightKg,
                goalWeight: viewModel.user?.targetWeightKg
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

    // MARK: – Demo Chat Replies
    private func demoReply(for text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("plan") || lower.contains("seguí") {
            return "¡Genial! Seguir el plan es lo más importante. Sigue así 💪"
        } else if lower.contains("hambre") {
            return "Es normal tener algo de hambre entre comidas. Prueba beber agua o tomar un snack ligero como frutos secos."
        } else if lower.contains("no pude") {
            return "No pasa nada, un día no define tu progreso. Mañana volvemos con todo 🙌"
        } else if lower.contains("duda") {
            return "Claro, cuéntame. Estoy aquí para ayudarte con lo que necesites."
        } else {
            return "Gracias por contarme. Reviso tu progreso y te digo cómo vas esta semana."
        }
    }
}

// MARK: – Loading Overlay View

struct AppLoadingOverlay: View {
    @State private var loadingRotation: Double = 0

    var body: some View {
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
}

#Preview {
    ContentView()
}
