import SwiftUI

/// Weekly shopping list auto-generated from the meal plan
struct ShoppingListView: View {
    @State private var viewModel = ShoppingListViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {

                    // Summary header
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lista de la Compra")
                                .font(.custom("Georgia-Bold", size: 24))
                                .foregroundStyle(Color.hbInk)
                            Text("Generada desde tu plan semanal")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.hbMuted)
                        }
                        Spacer()
                        // Progress pill
                        Text("\(viewModel.checkedCount)/\(viewModel.totalCount)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.hbSage)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.hbSage.opacity(0.12))
                            .cornerRadius(20)
                    }
                    .padding(.horizontal, 20)

                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.hbLine)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.hbSage)
                                .frame(width: viewModel.totalCount > 0
                                       ? geo.size.width * Double(viewModel.checkedCount) / Double(viewModel.totalCount)
                                       : 0)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 20)

                    // Categories
                    ForEach(viewModel.items) { category in
                        categorySection(category)
                    }

                    // Uncheck all button
                    if viewModel.checkedCount > 0 {
                        Button {
                            viewModel.uncheckAll()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Desmarcar todo")
                                    .fontWeight(.medium)
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hbMuted)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer().frame(height: 100) // Space for tab bar
                }
                .padding(.top, 8)
            }
            .background(Color.hbVanilla)
            .task { viewModel.loadFromMealPlan() }
        }
    }

    // MARK: — Category Section

    private func categorySection(_ category: ShoppingListViewModel.ShoppingCategory) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Category header
            HStack(spacing: 8) {
                Text(category.icon)
                    .font(.system(size: 16))
                Text(category.name.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.hbSage)
                    .tracking(2)
                Spacer()
                let checked = category.items.filter(\.checked).count
                if checked > 0 {
                    Text("\(checked)/\(category.items.count)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.hbMuted)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)

            // Items
            VStack(spacing: 0) {
                ForEach(Array(category.items.enumerated()), id: \.element.id) { index, item in
                    Button {
                        viewModel.toggleItem(categoryId: category.id, itemId: item.id)
                    } label: {
                        HStack(spacing: 14) {
                            // Checkbox
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(item.checked ? Color.hbSage : Color.hbLine, lineWidth: 1.5)
                                    .frame(width: 22, height: 22)
                                if item.checked {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.hbSage)
                                        .frame(width: 22, height: 22)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                }
                            }

                            // Name
                            Text(item.name)
                                .font(.system(size: 14))
                                .foregroundStyle(item.checked ? Color.hbMuted : Color.hbInk)
                                .strikethrough(item.checked, color: Color.hbMuted)

                            Spacer()

                            // Quantity
                            Text(item.quantity)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hbMuted)
                        }
                        .padding(.vertical, 11)
                        .padding(.horizontal, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if index < category.items.count - 1 {
                        Rectangle()
                            .fill(Color.hbLine)
                            .frame(height: 1)
                            .padding(.leading, 56)
                            .padding(.trailing, 20)
                    }
                }
            }
            .background(Color.hbPaper)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.hbLine, lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}
