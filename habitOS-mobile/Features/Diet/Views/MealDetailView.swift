import SwiftUI

/// Detailed view of a single meal — recipe, macros, ingredients, instructions
struct MealDetailView: View {
    let mealType: String
    let meal: MealDetail
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: – Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mealType.uppercased())
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.hbSage)
                            .tracking(2)

                        Text(meal.name)
                            .font(.custom("Georgia", size: 24, relativeTo: .title2))
                            .foregroundStyle(Color.hbInk)

                        HStack(spacing: 16) {
                            if let time = meal.time {
                                Label(time, systemImage: "clock")
                                    .font(.caption)
                                    .foregroundStyle(Color.hbMuted)
                            }
                            if let prep = meal.prepTimeMinutes {
                                Label("\(prep) min prep", systemImage: "timer")
                                    .font(.caption)
                                    .foregroundStyle(Color.hbMuted)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: – Macros
                    macrosCard

                    // MARK: – Ingredients
                    if let ingredients = meal.ingredients, !ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("INGREDIENTES")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.hbSage)
                                .tracking(2)

                            ForEach(ingredients) { ingredient in
                                HStack(spacing: 12) {
                                    Image(systemName: "circle")
                                        .font(.system(size: 8))
                                        .foregroundStyle(Color.hbSage)
                                    Text(ingredient.name)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.hbInk)
                                    Spacer()
                                    if let qty = ingredient.quantity {
                                        Text(qty)
                                            .font(.caption)
                                            .foregroundStyle(Color.hbMuted)
                                    }
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.hbPaper)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
                        .padding(.horizontal)
                    }

                    // MARK: – Instructions
                    if let instructions = meal.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("PREPARACIÓN")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.hbSage)
                                .tracking(2)

                            let steps = instructions.split(separator: "\n")
                            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .frame(width: 24, height: 24)
                                        .background(Color.hbSage)
                                        .cornerRadius(12)

                                    Text(step.trimmingCharacters(in: .whitespaces))
                                        .font(.subheadline)
                                        .foregroundStyle(Color.hbInk)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.hbPaper)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
                        .padding(.horizontal)
                    }

                    // MARK: – Alternatives
                    if let alternatives = meal.alternatives, !alternatives.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("ALTERNATIVAS")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.hbSage)
                                .tracking(2)

                            ForEach(alternatives, id: \.self) { alt in
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                        .font(.caption)
                                        .foregroundStyle(Color.hbSage)
                                    Text(alt)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.hbInk)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color.hbPaper)
                        .cornerRadius(18)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
                        .padding(.horizontal)
                    }

                    // MARK: – Action Buttons
                    VStack(spacing: 12) {
                        Button {} label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Seguí esta comida")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.hbSage)
                            .foregroundStyle(.white)
                            .cornerRadius(14)
                        }

                        Button {} label: {
                            HStack {
                                Image(systemName: "pencil.circle")
                                Text("Comí algo diferente")
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.hbInk.opacity(0.06))
                            .foregroundStyle(Color.hbInk.opacity(0.7))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.hbLine, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal)

                    Spacer().frame(height: 20)
                }
                .padding(.top, 24)
            }
            .background(Color.hbVanilla)
            .navigationTitle(mealType)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(Color.hbSage)
                }
            }
        }
    }

    // MARK: – Macros Card

    private var macrosCard: some View {
        VStack(spacing: 16) {
            Text("MACROS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbSage)
                .tracking(2)

            HStack(spacing: 0) {
                if let cal = meal.calories {
                    macroItem(label: "Calorías", value: "\(cal)", unit: "kcal", percent: nil)
                }
                divider
                if let p = meal.proteinG {
                    macroItem(label: "Proteína", value: "\(p)", unit: "g", percent: proteinPercent)
                }
                divider
                if let c = meal.carbsG {
                    macroItem(label: "Carbos", value: "\(c)", unit: "g", percent: carbsPercent)
                }
                divider
                if let f = meal.fatsG {
                    macroItem(label: "Grasas", value: "\(f)", unit: "g", percent: fatsPercent)
                }
            }

            if let fiber = meal.fiberG {
                HStack {
                    Text("Fibra")
                        .font(.caption)
                        .foregroundStyle(Color.hbMuted)
                    Spacer()
                    Text("\(fiber)g")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.hbInk)
                }
            }
        }
        .padding(18)
        .background(Color.hbPaper)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
        .padding(.horizontal)
    }

    private func macroItem(label: String, value: String, unit: String, percent: Double?) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.hbMuted)
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hbInk)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(Color.hbMuted)
            }
            if let pct = percent {
                // Mini progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.hbLine).frame(height: 4)
                        Capsule().fill(Color.hbSage).frame(width: geo.size.width * pct, height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle().fill(Color.hbLine).frame(width: 1, height: 40)
    }

    // Calculate percentages relative to a 2200 cal diet
    private var proteinPercent: Double? {
        guard let p = meal.proteinG else { return nil }
        return min(Double(p) / 165.0, 1.0)
    }
    private var carbsPercent: Double? {
        guard let c = meal.carbsG else { return nil }
        return min(Double(c) / 220.0, 1.0)
    }
    private var fatsPercent: Double? {
        guard let f = meal.fatsG else { return nil }
        return min(Double(f) / 73.0, 1.0)
    }
}
