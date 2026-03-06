import SwiftUI
import Charts

struct ProgressChartView: View {
    let streaks: [StreakPoint]
    let weeklySummary: WeeklySummary?

    @State private var selectedTimeRange = 0
    private let timeRanges = ["1S", "1M", "3M", "Todo"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HBTokens.sectionGap) {
                Text("Tu Progreso")
                    .font(.hbSerifBold(30))
                    .foregroundStyle(Color.hbInk)
                    .staggered(index: 0)

                if let summary = weeklySummary {
                    weightCard(summary).staggered(index: 1)
                }
                adherenceChart.staggered(index: 2)
                streakChart.staggered(index: 3)
                HBPrimaryButton("Registrar peso", icon: "scalemass") {}.staggered(index: 4)
                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
    }

    private func weightCard(_ s: WeeklySummary) -> some View {
        HBCard(highlighted: s.weightDeltaKg < 0) {
            VStack(spacing: 20) {
                HStack {
                    HBSectionHeader("Peso", icon: "scalemass")
                    Spacer()
                    HStack(spacing: 2) {
                        ForEach(0..<timeRanges.count, id: \.self) { i in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) { selectedTimeRange = i }
                            } label: {
                                Text(timeRanges[i])
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(selectedTimeRange == i ? Color.hbVanilla : Color.hbMuted2)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(
                                        selectedTimeRange == i ? Color.hbSage : Color.clear,
                                        in: RoundedRectangle(cornerRadius: 6)
                                    )
                            }
                        }
                    }
                    .padding(3)
                    .background(Color.hbVanilla, in: RoundedRectangle(cornerRadius: HBTokens.radiusSmall))
                    .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusSmall).stroke(Color.hbLine, lineWidth: 1))
                }

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("ACTUAL")
                            .font(.hbKicker(9))
                            .tracking(3)
                            .foregroundStyle(Color.hbMuted2)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text(String(format: "%.1f", s.currentWeightKg))
                                .font(.hbSerifBold(36))
                                .foregroundStyle(Color.hbInk)
                            Text("kg")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.hbMuted2)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 8) {
                        HBBadge(text: String(format: "%+.1f kg", s.weightDeltaKg), style: .accent)
                        Text("Obj: 78.0 kg")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.hbSage)
                    }
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3).fill(Color.hbSageBg)
                        RoundedRectangle(cornerRadius: 3).fill(Color.hbSage)
                            .frame(width: geo.size.width * 0.54)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private var adherenceChart: some View {
        HBCard {
            VStack(alignment: .leading, spacing: 16) {
                HBSectionHeader("Adherencia", icon: "chart.bar")
                Chart(streaks) { p in
                    BarMark(x: .value("Día", p.dayLabel), y: .value("V", p.streakValue))
                        .foregroundStyle(Color.hbSage.gradient)
                        .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel().foregroundStyle(Color.hbMuted2)
                        AxisGridLine().foregroundStyle(Color.hbLine.opacity(0.6))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.hbMuted) }
                }
                .frame(height: 180)
            }
        }
    }

    private var streakChart: some View {
        HBCard {
            VStack(alignment: .leading, spacing: 16) {
                HBSectionHeader("Tendencia", icon: "arrow.up.right")
                Chart(streaks) { p in
                    AreaMark(x: .value("D", p.dayLabel), y: .value("R", p.streakValue))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(colors: [Color.hbSage.opacity(0.12), Color.clear],
                                           startPoint: .top, endPoint: .bottom)
                        )
                    LineMark(x: .value("D", p.dayLabel), y: .value("R", p.streakValue))
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .foregroundStyle(Color.hbSage)
                    PointMark(x: .value("D", p.dayLabel), y: .value("R", p.streakValue))
                        .symbolSize(20).foregroundStyle(Color.hbSage)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel().foregroundStyle(Color.hbMuted2)
                        AxisGridLine().foregroundStyle(Color.hbLine.opacity(0.6))
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.hbMuted) }
                }
                .frame(height: 180)
            }
        }
    }
}
