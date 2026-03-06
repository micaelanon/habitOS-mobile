import SwiftUI

struct DashboardHomeView: View {
    let user: UserProfile?
    let macroSummary: MacroSummary?
    let dailyTasks: [DailyTask]
    let dailyProgress: Double
    let completedCount: Int
    let totalCount: Int
    let nextMeal: NextMeal?
    let weeklySummary: WeeklySummary?
    let lastCoachMessage: ChatMessage?
    let waterLiters: Double
    let waterTarget: Double
    let onToggleTask: (DailyTask) -> Void
    let onAddWater: (Double) -> Void

    @State private var isFABExpanded = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.hbVanilla.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: HBTokens.sectionGap) {

                    // ── Header: logo + greeting ──
                    VStack(alignment: .leading, spacing: 12) {
                        HBLogoView(size: 20)
                        Text(greetingText)
                            .font(.hbSerifBold(30))
                            .foregroundStyle(Color.hbInk)
                        Text(currentDateString)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.hbMuted)
                    }
                    .padding(.top, 8)
                    .staggered(index: 0)

                    // ── Hero: progress ring ──
                    heroCard
                        .staggered(index: 1)

                    // ── Macros ──
                    if let macros = macroSummary {
                        macroCard(macros)
                            .staggered(index: 2)
                    }

                    // ── Water ──
                    HBCard {
                        HBWaterTracker(
                            currentLiters: waterLiters,
                            targetLiters: waterTarget,
                            onAdd: onAddWater
                        )
                    }
                    .staggered(index: 3)

                    // ── Tasks ──
                    tasksSection.staggered(index: 4)

                    // ── Next Meal ──
                    if let nextMeal { nextMealSection(nextMeal).staggered(index: 5) }

                    // ── Weekly ──
                    if let summary = weeklySummary { weeklySection(summary).staggered(index: 6) }

                    // ── Coach ──
                    if let msg = lastCoachMessage { coachSection(msg).staggered(index: 7) }

                    Spacer(minLength: 80)
                }
                .padding(.horizontal, HBTokens.padScreen)
            }

            if isFABExpanded {
                Color.hbInk.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) { isFABExpanded = false }
                    }
            }

            HBFloatingActionButton(isExpanded: $isFABExpanded)
                .padding(.trailing, HBTokens.padScreen)
                .padding(.bottom, 20)
        }
    }

    // ═══ Hero ═══
    private var heroCard: some View {
        HBCard(highlighted: dailyProgress >= 0.8) {
            VStack(spacing: 20) {
                HBProgressRing(
                    progress: dailyProgress,
                    size: 120,
                    lineWidth: 10,
                    label: "\(Int(dailyProgress * 100))%"
                )
                VStack(spacing: 4) {
                    Text("\(completedCount) de \(totalCount) objetivos")
                        .font(.hbSerif(18, weight: .bold))
                        .foregroundStyle(Color.hbInk)
                    Text("completados hoy")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.hbMuted)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // ═══ Macros ═══
    private func macroCard(_ macros: MacroSummary) -> some View {
        HBCard {
            VStack(spacing: 18) {
                VStack(spacing: 4) {
                    Text("\(macros.calories)")
                        .font(.hbSerifBold(36))
                        .foregroundStyle(Color.hbInk)
                    Text("KCAL OBJETIVO")
                        .font(.hbKicker(9.5))
                        .tracking(3)
                        .foregroundStyle(Color.hbMuted2)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 0) {
                    macroCol("Proteína", g: macros.protein)
                    vDiv
                    macroCol("Carbos", g: macros.carbs)
                    vDiv
                    macroCol("Grasas", g: macros.fats)
                }
            }
        }
    }

    private func macroCol(_ label: String, g: Int) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(g)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.hbInk)
                Text("g")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hbMuted2)
            }
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.hbSage)
        }
        .frame(maxWidth: .infinity)
    }

    private var vDiv: some View {
        Rectangle().fill(Color.hbLine).frame(width: 1, height: 38)
    }

    // ═══ Tasks ═══
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HBSectionHeader("Objetivos de hoy", icon: "checklist", trailing: "\(completedCount)/\(totalCount)")
            HBCard {
                VStack(spacing: 0) {
                    let sorted = dailyTasks.sorted { !$0.isCompleted && $1.isCompleted }
                    ForEach(Array(sorted.enumerated()), id: \.element.id) { index, task in
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { onToggleTask(task) }
                        } label: {
                            HStack(spacing: 14) {
                                ZStack {
                                    Circle()
                                        .stroke(task.isCompleted ? Color.hbSage : Color.hbLine, lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    if task.isCompleted {
                                        Circle().fill(Color.hbSage).frame(width: 22, height: 22)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.hbVanilla)
                                    }
                                }
                                Text(task.title)
                                    .font(.system(size: 14))
                                    .foregroundStyle(task.isCompleted ? Color.hbMuted2 : Color.hbInk)
                                    .strikethrough(task.isCompleted, color: Color.hbMuted2)
                                Spacer()
                                Image(systemName: catIcon(task.category))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.hbSage.opacity(0.6))
                            }
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        if index < sorted.count - 1 { HBDivider(indent: 36) }
                    }
                }
            }
        }
    }

    // ═══ Next Meal ═══
    private func nextMealSection(_ meal: NextMeal) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HBSectionHeader("Próxima comida", icon: "fork.knife")
            HBCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(meal.mealName)
                            .font(.hbSerif(18, weight: .bold))
                            .foregroundStyle(Color.hbInk)
                        Spacer()
                        Text(meal.timeRange)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hbMuted2)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(meal.items, id: \.self) { item in
                            HStack(spacing: 10) {
                                Circle().fill(Color.hbSage.opacity(0.5)).frame(width: 4, height: 4)
                                Text(item).font(.system(size: 14)).foregroundStyle(Color.hbMuted)
                            }
                        }
                    }
                    HStack {
                        HBGhostButton("Ver receta", icon: "book") {}
                        Spacer()
                        HBPrimaryButton("Ya comí ✓") {}.frame(width: 130)
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // ═══ Weekly ═══
    private func weeklySection(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HBSectionHeader("Resumen semanal", icon: "chart.bar")
            HBCard {
                VStack(spacing: 16) {
                    statRow("Adherencia", val: "\(summary.adherencePercent)%",
                            prog: Double(summary.adherencePercent) / 100.0)
                    HBDivider()
                    statRow("Peso", val: String(format: "%.1f kg", summary.currentWeightKg),
                            badge: String(format: "%+.1f", summary.weightDeltaKg))
                    HBDivider()
                    statRow("Agua media", val: String(format: "%.1fL", summary.avgWaterLiters))
                    HBDivider()
                    statRow("Pasos", val: "\(summary.avgSteps)")
                }
            }
        }
    }

    // ═══ Coach ═══
    private func coachSection(_ msg: ChatMessage) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HBSectionHeader("Tu coach", icon: "message")
            HBCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Circle()
                            .fill(Color.hbSageBg)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.hbSage)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text(user?.coachName ?? "Coach")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.hbInk)
                            Text("Hace 1h")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.hbMuted2)
                        }
                    }
                    Text(msg.text)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.hbMuted)
                        .lineSpacing(4)
                        .lineLimit(3)
                    HStack { Spacer(); HBGhostButton("Ir al chat →") {} }
                }
            }
        }
    }

    // ═══ Helpers ═══
    private func statRow(_ label: String, val: String, prog: Double? = nil, badge: String? = nil) -> some View {
        HStack(spacing: 10) {
            Text(label).font(.system(size: 14)).foregroundStyle(Color.hbMuted)
            if let prog {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.hbSageBg)
                        RoundedRectangle(cornerRadius: 3).fill(Color.hbSage)
                            .frame(width: max(geo.size.width * prog, 4))
                    }
                }
                .frame(height: 6)
            }
            Spacer()
            Text(val)
                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                .foregroundStyle(Color.hbInk)
            if let badge {
                HBBadge(text: badge, style: .accent)
            }
        }
    }

    private var greetingText: String {
        let h = Calendar.current.component(.hour, from: Date())
        let n = user?.firstName ?? ""
        switch h {
        case 5..<12: return "Buenos días, \(n)"
        case 12..<20: return "Buenas tardes, \(n)"
        default: return "Buenas noches, \(n)"
        }
    }

    private var currentDateString: String {
        let f = DateFormatter(); f.locale = Locale(identifier: "es_ES")
        f.dateFormat = "EEEE, d 'de' MMMM"; return f.string(from: Date()).capitalized
    }

    private func catIcon(_ c: DailyTask.TaskCategory) -> String {
        switch c {
        case .nutrition: "leaf"; case .hydration: "drop"
        case .activity: "figure.walk"; case .sleep: "moon"
        case .supplement: "pill"; case .habit: "circle.dotted"
        case .other: "ellipsis"
        }
    }
}
