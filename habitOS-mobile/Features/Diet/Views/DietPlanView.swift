import SwiftUI

/// Weekly diet plan view with day selector and meal cards
struct DietPlanView: View {
    @State private var viewModel = DietViewModel()
    @State private var selectedMeal: SelectedMeal?
    let userId: UUID

    struct SelectedMeal: Identifiable {
        let id = UUID()
        let type: String
        let meal: MealDetail
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: – Day Selector
                HStack(spacing: 6) {
                    ForEach(viewModel.dayInitials, id: \.day) { item in
                        Button {
                            withAnimation(.spring(duration: 0.2)) {
                                viewModel.selectedDay = item.day
                            }
                        } label: {
                            Text(item.initial)
                                .font(.system(size: 14, weight: .semibold))
                                .frame(width: 40, height: 40)
                                .background(
                                    viewModel.selectedDay == item.day
                                        ? Color.hbSage
                                        : Color.hbPaper
                                )
                                .foregroundStyle(
                                    viewModel.selectedDay == item.day
                                        ? .white
                                        : Color.hbInk
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            viewModel.selectedDay == item.day
                                                ? Color.clear
                                                : Color.hbLine,
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
                .padding(.horizontal)

                // MARK: – Day Header
                if let plan = viewModel.plan {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.dayName.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.hbSage)
                            .tracking(2)

                        HStack(spacing: 16) {
                            macroChip(label: "kcal", value: "\(plan.dailyCalories ?? 0)")
                            macroChip(label: "P", value: "\(plan.dailyProteinG ?? 0)g")
                            macroChip(label: "C", value: "\(plan.dailyCarbsG ?? 0)g")
                            macroChip(label: "G", value: "\(plan.dailyFatsG ?? 0)g")
                        }
                    }
                    .padding(.horizontal)
                }

                // MARK: – Meals
                if let dayMeals = viewModel.todayMeals {
                    ForEach(dayMeals.allMeals, id: \.type) { item in
                        mealCard(type: item.type, meal: item.meal)
                            .onTapGesture {
                                selectedMeal = SelectedMeal(type: item.type, meal: item.meal)
                            }
                    }
                } else {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundStyle(Color.hbMuted)
                        Text("No hay plan para este día")
                            .font(.subheadline)
                            .foregroundStyle(Color.hbMuted)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(60)
                }

                Spacer().frame(height: 20)
            }
            .padding(.top)
        }
        .background(Color.hbVanilla)
        .sheet(item: $selectedMeal) { item in
            MealDetailView(mealType: item.type, meal: item.meal)
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadPlan(userId: userId)
        }
    }

    // MARK: – Meal Card

    private func mealCard(type: String, meal: MealDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(mealEmoji(for: type))
                    .font(.title3)
                Text("\(type.uppercased())")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hbSage)
                    .tracking(1.5)
                if let time = meal.time {
                    Text("· \(time)")
                        .font(.caption)
                        .foregroundStyle(Color.hbMuted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.hbMuted)
            }

            // Meal name
            Text(meal.name)
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(Color.hbInk)

            // Ingredients preview
            if let ingredients = meal.ingredients?.prefix(3) {
                ForEach(Array(ingredients), id: \.name) { ing in
                    Text("• \(ing.name)\(ing.quantity.map { " · \(String($0))" } ?? "")")
                        .font(.caption)
                        .foregroundStyle(Color.hbMuted)
                }
                if (meal.ingredients?.count ?? 0) > 3 {
                    Text("+ \((meal.ingredients?.count ?? 0) - 3) más")
                        .font(.caption)
                        .foregroundStyle(Color.hbSage)
                }
            }

            // Macros
            if let cal = meal.calories {
                HStack(spacing: 12) {
                    Text("\(cal) kcal")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.hbInk)
                    if let p = meal.proteinG { Text("P:\(p)g").font(.caption).foregroundStyle(Color.hbMuted) }
                    if let c = meal.carbsG { Text("C:\(c)g").font(.caption).foregroundStyle(Color.hbMuted) }
                    if let f = meal.fatsG { Text("G:\(f)g").font(.caption).foregroundStyle(Color.hbMuted) }
                }
                .padding(.top, 4)
            }
        }
        .padding(18)
        .background(Color.hbPaper)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: – Helpers

    private func macroChip(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.hbMuted)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbInk)
        }
    }

    private func mealEmoji(for type: String) -> String {
        switch type.lowercased() {
        case "desayuno": return "🌅"
        case "media mañana": return "🍎"
        case "almuerzo": return "🍽"
        case "merienda": return "🍌"
        case "cena": return "🌙"
        default: return "🍴"
        }
    }
}
