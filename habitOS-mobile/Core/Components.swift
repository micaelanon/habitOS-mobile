import SwiftUI

// ═══════════════════════════════════════════════════════════════
// MARK: – HBCard
// Brand Manual: Paper card on Vanilla bg, Line border, 18px radius
// Shadow: 0 18px 48px rgba(0,0,0,.06)
// ═══════════════════════════════════════════════════════════════
struct HBCard<Content: View>: View {
    var highlighted: Bool = false
    let content: Content

    init(highlighted: Bool = false, @ViewBuilder content: () -> Content) {
        self.highlighted = highlighted
        self.content = content()
    }

    var body: some View {
        content
            .padding(HBTokens.padCard)
            .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: HBTokens.radiusLarge))
            .overlay(
                RoundedRectangle(cornerRadius: HBTokens.radiusLarge)
                    .stroke(highlighted ? Color.hbSage.opacity(0.5) : Color.hbLine, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 10)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Section Header (Kicker style)
// Brand Manual: Inter 600 uppercase, tracking .32em, color Sage
// ═══════════════════════════════════════════════════════════════
struct HBSectionHeader: View {
    let title: String
    let icon: String?
    let trailing: String?

    init(_ title: String, icon: String? = nil, trailing: String? = nil) {
        self.title = title; self.icon = icon; self.trailing = trailing
    }

    var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hbSage)
            }
            Text(title.uppercased())
                .font(.hbKicker(11))
                .tracking(3)
                .foregroundStyle(Color.hbSage)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hbMuted2)
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Progress Ring
// Sage accent only
// ═══════════════════════════════════════════════════════════════
struct HBProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let label: String?

    @State private var animatedProgress: Double = 0

    init(progress: Double, size: CGFloat = 100, lineWidth: CGFloat = 10, label: String? = nil) {
        self.progress = min(max(progress, 0), 1)
        self.size = size
        self.lineWidth = lineWidth
        self.label = label
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.hbLine, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(Color.hbSage, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if let label {
                Text(label)
                    .font(.hbSerifBold(size * 0.22))
                    .foregroundStyle(Color.hbInk)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) { animatedProgress = progress }
        }
        .onChange(of: progress) { _, newVal in
            withAnimation(.easeOut(duration: 0.4)) { animatedProgress = newVal }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Badge
// Sage-only tones, no multi-color semantics
// ═══════════════════════════════════════════════════════════════
struct HBBadge: View {
    let text: String
    let style: BadgeStyle

    enum BadgeStyle { case accent, subtle, muted }

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
            .tracking(0.5)
            .foregroundStyle(fgColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(bgColor, in: RoundedRectangle(cornerRadius: HBTokens.radiusSmall))
    }

    private var bgColor: Color {
        switch style {
        case .accent: Color.hbSageBg
        case .subtle: Color.hbLine.opacity(0.5)
        case .muted:  Color.hbVanilla
        }
    }

    private var fgColor: Color {
        switch style {
        case .accent: Color.hbSage
        case .subtle: Color.hbInk
        case .muted:  Color.hbMuted
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Buttons
// Brand Manual: Sage bg, Vanilla/Paper text, radius 14
// ═══════════════════════════════════════════════════════════════
struct HBPrimaryButton: View {
    let label: String
    let icon: String?
    let action: () -> Void

    init(_ label: String, icon: String? = nil, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon { Image(systemName: icon).font(.system(size: 14, weight: .medium)) }
                Text(label).font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(Color.hbVanilla)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.hbSage, in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium))
        }
    }
}

struct HBGhostButton: View {
    let label: String
    let icon: String?
    let action: () -> Void

    init(_ label: String, icon: String? = nil, action: @escaping () -> Void) {
        self.label = label; self.icon = icon; self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon { Image(systemName: icon).font(.system(size: 12, weight: .medium)) }
                Text(label).font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(Color.hbSage)
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – FAB
// Sage-only, Paper labels
// ═══════════════════════════════════════════════════════════════
struct HBFloatingActionButton: View {
    @Binding var isExpanded: Bool
    var onAction: ((FABAction) -> Void)?

    enum FABAction: Int, CaseIterable {
        case journal, mealPhoto, weightLog, scanner
    }

    private let actions: [(icon: String, label: String)] = [
        ("pencil.line",        "Diario"),
        ("camera",             "Foto comida"),
        ("scalemass",          "Registrar peso"),
        ("barcode.viewfinder", "Escáner"),
    ]

    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            if isExpanded {
                ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
                    Button {
                        if let fabAction = FABAction(rawValue: index) {
                            onAction?(fabAction)
                        }
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) { isExpanded = false }
                    } label: {
                    HStack(spacing: 10) {
                        Text(action.label)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.hbInk)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium))
                            .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusMedium).stroke(Color.hbLine, lineWidth: 1))
                            .shadow(color: .black.opacity(0.06), radius: 12, y: 4)

                        Image(systemName: action.icon)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.hbVanilla)
                            .frame(width: 40, height: 40)
                            .background(Color.hbSage, in: Circle())
                    }
                    }
                    .buttonStyle(.plain)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity)
                            .animation(.spring(response: 0.35, dampingFraction: 0.7)
                                       .delay(Double(actions.count - 1 - index) * 0.05)),
                        removal: .opacity.animation(.easeIn(duration: 0.15))
                    ))
                }
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) { isExpanded.toggle() }
            } label: {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.hbVanilla)
                    .frame(width: 52, height: 52)
                    .background(Color.hbSage, in: Circle())
                    .shadow(color: Color.hbSage.opacity(0.25), radius: 16, y: 8)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Water Tracker
// Sage only — no blue
// ═══════════════════════════════════════════════════════════════
struct HBWaterTracker: View {
    let currentLiters: Double
    let targetLiters: Double
    let onAdd: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "drop")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.hbSage)
                Text("HIDRATACIÓN")
                    .font(.hbKicker(10))
                    .tracking(2.5)
                    .foregroundStyle(Color.hbSage)
                Spacer()
                Text(String(format: "%.1fL", currentLiters))
                    .font(.hbSerifBold(18))
                    .foregroundStyle(Color.hbInk)
                Text(String(format: "/ %.1fL", targetLiters))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.hbMuted2)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.hbSageBg)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.hbSage)
                        .frame(width: geo.size.width * min(currentLiters / targetLiters, 1.0))
                        .animation(.easeOut(duration: 0.3), value: currentLiters)
                }
            }
            .frame(height: 8)

            HStack(spacing: 10) {
                waterBtn("+ 250ml") { onAdd(0.25) }
                waterBtn("+ 500ml") { onAdd(0.5) }
                Spacer()
            }
        }
    }

    private func waterBtn(_ text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.hbSage)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: HBTokens.radiusSmall))
                .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusSmall).stroke(Color.hbSage.opacity(0.2), lineWidth: 1))
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Divider
// Line color
// ═══════════════════════════════════════════════════════════════
struct HBDivider: View {
    var indent: CGFloat = 0
    var body: some View {
        Rectangle()
            .fill(Color.hbLine)
            .frame(height: 1)
            .padding(.leading, indent)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: – Logo View
// "habitOS" with "OS" in italic serif Sage
// ═══════════════════════════════════════════════════════════════
struct HBLogoView: View {
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: 0) {
            Text("habit")
                .font(.hbSerifBold(size))
                .foregroundStyle(Color.hbInk)
            Text("OS")
                .font(.hbSerifItalic(size))
                .foregroundStyle(Color.hbSage)
        }
    }
}
