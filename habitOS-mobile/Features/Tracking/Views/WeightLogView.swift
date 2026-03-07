import SwiftUI
import Charts

/// Weight tracking view with Swift Charts and history
struct WeightLogView: View {
    @State private var viewModel = TrackingViewModel()
    let userId: UUID
    var startWeight: Double?
    var goalWeight: Double?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // MARK: – Header Stats
                statsHeader

                // MARK: – Chart
                if !viewModel.weightLogs.isEmpty {
                    chartSection
                }

                // MARK: – History
                historySection

                Spacer().frame(height: 20)
            }
            .padding(.top)
        }
        .background(Color.hbVanilla)
        .overlay {
            if viewModel.savedConfirmation {
                savedToast
            }
        }
        .sheet(isPresented: $viewModel.showingEntrySheet) {
            WeightEntrySheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showingEntrySheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.hbSage)
                }
            }
        }
        .task {
            await viewModel.loadLogs(userId: userId, startWeight: startWeight, goalWeight: goalWeight)
        }
    }

    // MARK: – Stats Header

    private var statsHeader: some View {
        HStack(spacing: 0) {
            statBox(
                label: "ACTUAL",
                value: viewModel.currentWeight.map { String(format: "%.1f", $0) } ?? "—",
                unit: "kg",
                color: .hbInk
            )
            divider
            statBox(
                label: "INICIO",
                value: startWeight.map { String(format: "%.1f", $0) } ?? "—",
                unit: "kg",
                color: .hbMuted
            )
            divider
            statBox(
                label: "OBJETIVO",
                value: goalWeight.map { String(format: "%.1f", $0) } ?? "—",
                unit: "kg",
                color: .hbSage
            )
        }
        .padding(18)
        .background(Color.hbPaper)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
        .padding(.horizontal)
    }

    private func statBox(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbMuted)
                .tracking(1)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(Color.hbMuted)
            }
            if let delta = viewModel.lastDelta, label == "ACTUAL" {
                HStack(spacing: 2) {
                    Image(systemName: delta <= 0 ? "arrow.down.right" : "arrow.up.right")
                        .font(.caption2)
                    Text(String(format: "%.1f", abs(delta)))
                        .font(.caption)
                }
                .foregroundStyle(delta <= 0 ? Color.hbSage : Color.orange)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.hbLine)
            .frame(width: 1, height: 40)
    }

    // MARK: – Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TENDENCIA")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbSage)
                .tracking(2)
                .padding(.horizontal)

            Chart {
                ForEach(viewModel.weightLogs.reversed()) { log in
                    LineMark(
                        x: .value("Fecha", log.loggedAt),
                        y: .value("Peso", log.weightKg)
                    )
                    .foregroundStyle(Color.hbSage)
                    .lineStyle(StrokeStyle(lineWidth: 2))

                    AreaMark(
                        x: .value("Fecha", log.loggedAt),
                        y: .value("Peso", log.weightKg)
                    )
                    .foregroundStyle(
                        .linearGradient(
                            colors: [Color.hbSage.opacity(0.2), Color.hbSage.opacity(0.02)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    PointMark(
                        x: .value("Fecha", log.loggedAt),
                        y: .value("Peso", log.weightKg)
                    )
                    .foregroundStyle(Color.hbSage)
                    .symbolSize(20)
                }

                // Goal reference line
                if let goal = goalWeight {
                    RuleMark(y: .value("Objetivo", goal))
                        .foregroundStyle(Color.hbSage.opacity(0.4))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .trailing, alignment: .trailing) {
                            Text("Objetivo")
                                .font(.caption2)
                                .foregroundStyle(Color.hbSage.opacity(0.6))
                        }
                }
            }
            .chartYScale(domain: chartYDomain)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(Color.hbLine)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                        .foregroundStyle(Color.hbLine)
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(18)
        .background(Color.hbPaper)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
        .padding(.horizontal)
    }

    private var chartYDomain: ClosedRange<Double> {
        let weights = viewModel.weightLogs.map(\.weightKg)
        let minW = (weights.min() ?? 70) - 2
        let maxW = (weights.max() ?? 90) + 2
        return minW...maxW
    }

    // MARK: – History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HISTORIAL")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbSage)
                .tracking(2)
                .padding(.horizontal)

            if viewModel.weightLogs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "scalemass")
                        .font(.largeTitle)
                        .foregroundStyle(Color.hbMuted)
                    Text("Registra tu primer peso para\nempezar a ver tu progreso.")
                        .font(.subheadline)
                        .foregroundStyle(Color.hbMuted)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.weightLogs.enumerated()), id: \.element.id) { index, log in
                        historyRow(log: log, prevLog: index + 1 < viewModel.weightLogs.count ? viewModel.weightLogs[index + 1] : nil)
                        if index < viewModel.weightLogs.count - 1 {
                            Divider().padding(.leading, 58)
                        }
                    }
                }
                .padding(14)
                .background(Color.hbPaper)
                .cornerRadius(18)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
                .padding(.horizontal)
            }
        }
    }

    private func historyRow(log: WeightLog, prevLog: WeightLog?) -> some View {
        HStack(spacing: 14) {
            VStack {
                Text(log.loggedAt.formatted(.dateTime.day()))
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(Color.hbInk)
                Text(log.loggedAt.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(Color.hbMuted)
            }
            .frame(width: 38)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(format: "%.1f kg", log.weightKg))
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(Color.hbInk)
                if let note = log.notes {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(Color.hbMuted)
                        .lineLimit(1)
                }
            }

            Spacer()

            if let prev = prevLog {
                let delta = log.weightKg - prev.weightKg
                HStack(spacing: 3) {
                    Image(systemName: delta <= 0 ? "arrow.down.right" : "arrow.up.right")
                        .font(.caption2)
                    Text(String(format: "%.1f", abs(delta)))
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundStyle(delta <= 0 ? Color.hbSage : Color.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((delta <= 0 ? Color.hbSage : Color.orange).opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: – Saved Toast

    private var savedToast: some View {
        VStack {
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("⚖️ Peso registrado")
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.hbSage)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: viewModel.savedConfirmation)
    }
}

// MARK: – Weight Entry Sheet

struct WeightEntrySheet: View {
    @Bindable var viewModel: TrackingViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                // Weight input
                VStack(spacing: 8) {
                    Text("PESO")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.hbSage)
                        .tracking(2)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        TextField("80.0", text: $viewModel.newWeight)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.hbInk)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 160)
                        Text("kg")
                            .font(.title2)
                            .foregroundStyle(Color.hbMuted)
                    }
                }

                // Optional: body fat
                HStack {
                    Text("% Grasa corporal")
                        .font(.subheadline)
                        .foregroundStyle(Color.hbInk)
                    Spacer()
                    TextField("—", text: $viewModel.newBodyFat)
                        .font(.system(.body, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("%")
                        .font(.subheadline)
                        .foregroundStyle(Color.hbMuted)
                }
                .padding(14)
                .background(Color.hbPaper)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hbLine, lineWidth: 1))

                // Notes
                TextField("Notas (opcional)", text: $viewModel.newNotes)
                    .font(.subheadline)
                    .padding(14)
                    .background(Color.hbPaper)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hbLine, lineWidth: 1))

                Spacer()

                // Save button
                Button {
                    Task { await viewModel.saveWeight() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        }
                        Text("Registrar peso")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.hbSage)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                }
                .disabled(viewModel.isLoading || viewModel.newWeight.isEmpty)

                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding(24)
            .background(Color.hbVanilla)
            .navigationTitle("Registrar peso")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { viewModel.showingEntrySheet = false }
                        .foregroundStyle(Color.hbSage)
                }
            }
        }
    }
}
