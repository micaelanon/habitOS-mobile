import SwiftUI

/// Product result card shown after a successful barcode scan
struct FoodProductCard: View {
    let product: OpenFoodFactsProduct
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header row
            HStack(alignment: .top, spacing: 14) {
                // Product photo
                AsyncImage(url: URL(string: product.imageURL ?? "")) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                            .frame(width: 64, height: 64)
                            .clipped()
                            .cornerRadius(10)
                    default:
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.hbSageBg)
                            .frame(width: 64, height: 64)
                            .overlay(Image(systemName: "photo").foregroundStyle(Color.hbSage))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName ?? "Producto desconocido")
                        .font(.hbSerifBold(16))
                        .foregroundStyle(Color.hbInk)
                        .lineLimit(2)
                    if let brand = product.brands, !brand.isEmpty {
                        Text(brand)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hbMuted)
                    }
                    if let grade = product.nutriscoreGrade {
                        NutriscoreBadge(grade: grade.uppercased())
                    }
                }
                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.hbMuted2)
                }
            }

            if let n = product.nutriments {
                Divider().background(Color.hbLine)

                // Macro grid
                HStack(spacing: 0) {
                    macroCell("Energía", value: n.energyKcal.map { "\(Int($0))" } ?? "–", unit: "kcal")
                    vdiv
                    macroCell("Proteínas", value: n.proteins.map { String(format: "%.1f", $0) } ?? "–", unit: "g")
                    vdiv
                    macroCell("Carbos", value: n.carbohydrates.map { String(format: "%.1f", $0) } ?? "–", unit: "g")
                    vdiv
                    macroCell("Grasas", value: n.fat.map { String(format: "%.1f", $0) } ?? "–", unit: "g")
                }

                Text("Por 100 g")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.hbMuted2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            // Add to diary button (stub)
            HBPrimaryButton("Añadir al diario", icon: "plus") {}
        }
        .padding(18)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
    }

    private func macroCell(_ label: String, value: String, unit: String) -> some View {
        VStack(spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.hbInk)
                Text(unit)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.hbMuted2)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.hbSage)
        }
        .frame(maxWidth: .infinity)
    }

    private var vdiv: some View {
        Rectangle()
            .fill(Color.hbLine)
            .frame(width: 1, height: 32)
    }
}

/// Nutri-Score color badge (A=green, E=red)
struct NutriscoreBadge: View {
    let grade: String

    private var color: Color {
        switch grade {
        case "A": return Color(red: 0.21, green: 0.65, blue: 0.33)
        case "B": return Color(red: 0.55, green: 0.78, blue: 0.30)
        case "C": return Color(red: 1.00, green: 0.82, blue: 0.12)
        case "D": return Color(red: 0.98, green: 0.54, blue: 0.16)
        case "E": return Color(red: 0.91, green: 0.26, blue: 0.19)
        default: return Color.hbMuted2
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Text("Nutri-Score")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white)
            Text(grade)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(color, in: RoundedRectangle(cornerRadius: 6))
    }
}
