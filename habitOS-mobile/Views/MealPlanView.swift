import SwiftUI

struct MealPlanView: View {
    let plan: NutritionPlan?
    let macroSummary: MacroSummary?
    @State private var showShopping = false
    @State private var selectedMealToLog: MealDetail?

    @State private var selectedDay: Int = {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }()

    private let dayLabels = ["L", "M", "X", "J", "V", "S", "D"]
    private let dayNames  = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]

    /// Convert selectedDay (0=Mon..6=Sun) to Calendar weekday (2=Mon..1=Sun)
    private var calendarWeekday: Int {
        selectedDay == 6 ? 1 : selectedDay + 2
    }

    private var todayMeals: [(type: String, meal: MealDetail)] {
        plan?.mealPlan.meals(for: calendarWeekday)?.allMeals ?? []
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HBTokens.sectionGap) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mi Dieta")
                        .font(.hbSerifBold(30))
                        .foregroundStyle(Color.hbInk)
                    Text(dayNames[selectedDay])
                        .font(.system(size: 13))
                        .foregroundStyle(Color.hbMuted)
                }
                .staggered(index: 0)

                // Day selector
                HStack(spacing: 6) {
                    ForEach(0..<7, id: \.self) { i in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) { selectedDay = i }
                        } label: {
                            Text(dayLabels[i])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(selectedDay == i ? Color.hbVanilla : Color.hbMuted)
                                .frame(maxWidth: .infinity)
                                .frame(height: 40)
                                .background(
                                    selectedDay == i ? Color.hbSage : Color.hbPaper,
                                    in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium)
                                )
                                .overlay(
                                    selectedDay != i
                                    ? RoundedRectangle(cornerRadius: HBTokens.radiusMedium).stroke(Color.hbLine, lineWidth: 1) : nil
                                )
                        }
                    }
                }
                .staggered(index: 1)

                // Macros
                if let macros = macroSummary {
                    HBCard {
                        HStack(spacing: 0) {
                            macroCol("Calorías", value: "\(macros.calories)", unit: "kcal")
                            vdiv
                            macroCol("Proteína", value: "\(macros.protein)", unit: "g")
                            vdiv
                            macroCol("Carbos", value: "\(macros.carbs)", unit: "g")
                            vdiv
                            macroCol("Grasas", value: "\(macros.fats)", unit: "g")
                        }
                    }
                    .staggered(index: 2)
                }

                // Meals for selected day
                ForEach(Array(todayMeals.enumerated()), id: \.element.type) { index, entry in
                    let (mealType, meal) = entry
                    HBCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Text(mealTypeEmoji(mealType))
                                    .font(.system(size: 16))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mealType)
                                        .font(.hbSerif(16, weight: .bold))
                                        .foregroundStyle(Color.hbInk)
                                    if let time = meal.time {
                                        Text(time)
                                            .font(.system(size: 12))
                                            .foregroundStyle(Color.hbMuted2)
                                    }
                                }

                                Spacer()

                                Button {
                                    selectedMealToLog = meal
                                } label: {
                                    Image(systemName: "camera")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.hbSage)
                                        .frame(width: 32, height: 32)
                                        .background(Color.hbSageBg, in: Circle())
                                }
                            }
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(meal.ingredients ?? [], id: \.name) { ingredient in
                                    HStack(spacing: 10) {
                                        Circle().fill(Color.hbSage.opacity(0.5)).frame(width: 4, height: 4)
                                        Text(ingredient.displayText)
                                            .font(.system(size: 14)).foregroundStyle(Color.hbMuted)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .staggered(index: 3 + index)
                }

                if todayMeals.isEmpty {
                    HBCard {
                        Text("No hay comidas planificadas para este día.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hbMuted)
                            .frame(maxWidth: .infinity)
                    }
                    .staggered(index: 3)
                }

                NavigationLink(destination: ShoppingListView()) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart").font(.system(size: 14, weight: .medium))
                        Text("Lista de la compra").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.hbVanilla)
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.hbSage, in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium))
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.bottom, 60)
            .padding(.top, 24)
        }
        .background(Color.hbVanilla.ignoresSafeArea())
        .sheet(item: $selectedMealToLog) { meal in
            MealLogView(mealName: meal.name, mealItems: meal.ingredients?.map(\.displayText) ?? [])
        }
    }

    private func macroCol(_ label: String, value: String, unit: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value).font(.system(size: 16, weight: .bold, design: .monospaced)).foregroundStyle(Color.hbInk)
                Text(unit).font(.system(size: 10)).foregroundStyle(Color.hbMuted2)
            }
            Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(Color.hbSage)
        }
        .frame(maxWidth: .infinity)
    }

    private var vdiv: some View {
        Rectangle().fill(Color.hbLine).frame(width: 1, height: 36)
    }

    private func mealTypeEmoji(_ type: String) -> String {
        switch type {
        case "Desayuno": return "🌅"
        case "Media Mañana": return "🍎"
        case "Almuerzo": return "🍽"
        case "Merienda": return "🍌"
        case "Cena": return "🌙"
        default: return "🍴"
        }
    }
}
