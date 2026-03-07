import SwiftUI

/// Custom floating tab bar with rounded-square icon backgrounds
/// Clean, minimal transitions — no bounce effects
struct FloatingTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                tabButton(tab: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.hbLine.opacity(0.5), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    // MARK: – Tab Button

    private func tabButton(tab: TabItem) -> some View {
        let isSelected = selectedTab == tab.index

        return VStack(spacing: 6) {
            // Rounded-square icon background (static color to avoid flicker)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.hbInk.opacity(0.04))
                    .frame(width: 44, height: 44)

                Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.hbSage : Color.hbMuted)
            }

            // Label
            Text(tab.label)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color.hbSage : Color.hbMuted)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            // Force completely instant state change with zero animation propagation
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                selectedTab = tab.index
            }
        }
        .animation(nil, value: selectedTab)
    }

    // MARK: – Tab Data

    struct TabItem: Identifiable {
        let id = UUID()
        let index: Int
        let label: String
        let icon: String
        let iconFilled: String
    }

    private let tabs: [TabItem] = [
        TabItem(index: 0, label: "Hoy", icon: "house", iconFilled: "house.fill"),
        TabItem(index: 1, label: "Dieta", icon: "leaf", iconFilled: "leaf.fill"),
        TabItem(index: 2, label: "Chat", icon: "message", iconFilled: "message.fill"),
        TabItem(index: 3, label: "Progreso", icon: "chart.line.uptrend.xyaxis", iconFilled: "chart.line.uptrend.xyaxis.circle.fill"),
        TabItem(index: 4, label: "Perfil", icon: "person.crop.circle", iconFilled: "person.crop.circle.fill"),
    ]
}
