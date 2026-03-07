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

        return Button {
            selectedTab = tab.index
        } label: {
            VStack(spacing: 6) {
                // Rounded-square icon background
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.hbSage.opacity(0.15) : Color.hbInk.opacity(0.04))
                        .frame(width: 44, height: 44)

                    // Overlap two static images + opacity to bypass iOS 17 automatic symbol transitions
                    ZStack {
                        Image(systemName: tab.icon)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(Color.hbMuted)
                            .opacity(isSelected ? 0 : 1)

                        Image(systemName: tab.iconFilled)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color.hbSage)
                            .opacity(isSelected ? 1 : 0)
                    }
                }
                .animation(nil, value: isSelected)

                // Label
                Text(tab.label)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.hbSage : Color.hbMuted)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
