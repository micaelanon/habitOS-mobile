import SwiftUI

struct MealPlanView: View {
    let mealPlan: MealPlan?
    let macroSummary: MacroSummary?

    @State private var selectedDay: Int = {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }()

    private let dayLabels = ["L", "M", "X", "J", "V", "S", "D"]
    private let dayNames  = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]

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

                // Meals
                ForEach(Array((mealPlan?.meals ?? []).enumerated()), id: \.element.id) { index, meal in
                    HBCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(meal.mealName)
                                .font(.hbSerif(16, weight: .bold))
                                .foregroundStyle(Color.hbInk)
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(meal.items, id: \.self) { item in
                                    HStack(spacing: 10) {
                                        Circle().fill(Color.hbSage.opacity(0.5)).frame(width: 4, height: 4)
                                        Text(item).font(.system(size: 14)).foregroundStyle(Color.hbMuted)
                                    }
                                }
                            }
                        }
                    }
                    .staggered(index: 3 + index)
                }

                HBPrimaryButton("Lista de la compra", icon: "cart") {}
                    .staggered(index: 8)

                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
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
}
