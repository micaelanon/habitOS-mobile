import SwiftUI

/// Daily check-in journal — the heart of habitOS
struct JournalView: View {
    @State private var viewModel = JournalViewModel()
    let userId: UUID

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {

                // MARK: – Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("DIARIO")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.hbSage)
                        .tracking(3)
                    Text(viewModel.selectedDate.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                        .font(.custom("Georgia", size: 24, relativeTo: .title2))
                        .foregroundStyle(Color.hbInk)
                }
                .padding(.horizontal)

                // MARK: – Mood Selector
                sectionCard(title: "¿CÓMO TE SIENTES HOY?") {
                    HStack(spacing: 16) {
                        ForEach(moodOptions, id: \.symbol) { option in
                            Button {
                                withAnimation(.spring(duration: 0.2)) {
                                    viewModel.mood = option.value
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    Text(option.symbol)
                                        .font(.system(size: 32))
                                    Text(option.label)
                                        .font(.caption2)
                                        .foregroundStyle(viewModel.mood == option.value ? Color.hbInk : Color.hbMuted)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 4)
                                .background(
                                    viewModel.mood == option.value
                                        ? Color.hbSage.opacity(0.12)
                                        : Color.clear
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                }

                // MARK: – Energy Level
                sectionCard(title: "ENERGÍA") {
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { level in
                            Button {
                                withAnimation(.spring(duration: 0.2)) {
                                    viewModel.energyLevel = level
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: level <= (viewModel.energyLevel ?? 0) ? "bolt.fill" : "bolt")
                                        .font(.title3)
                                        .foregroundStyle(
                                            level <= (viewModel.energyLevel ?? 0) ? Color.hbSage : Color.hbMuted
                                        )
                                    Text("\(level)")
                                        .font(.caption)
                                        .foregroundStyle(Color.hbMuted)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }

                // MARK: – Sleep
                sectionCard(title: "😴 SUEÑO") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Horas")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            HStack(spacing: 8) {
                                Button { if viewModel.sleepHours > 0.5 { viewModel.sleepHours -= 0.5 } }
                                    label: { Image(systemName: "minus.circle").foregroundStyle(Color.hbSage) }
                                Text(String(format: "%.1f h", viewModel.sleepHours))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(Color.hbInk)
                                    .frame(width: 50, alignment: .center)
                                Button { viewModel.sleepHours += 0.5 }
                                    label: { Image(systemName: "plus.circle").foregroundStyle(Color.hbSage) }
                            }
                        }

                        HStack {
                            Text("Calidad")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            HStack(spacing: 8) {
                                ForEach(sleepQualities, id: \.value) { sq in
                                    Button {
                                        viewModel.sleepQuality = sq.value
                                    } label: {
                                        Text(sq.label)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                viewModel.sleepQuality == sq.value
                                                    ? Color.hbSage.opacity(0.15)
                                                    : Color.hbVanilla
                                            )
                                            .foregroundStyle(
                                                viewModel.sleepQuality == sq.value
                                                    ? Color.hbSage
                                                    : Color.hbMuted
                                            )
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(
                                                        viewModel.sleepQuality == sq.value
                                                            ? Color.hbSage
                                                            : Color.hbLine,
                                                        lineWidth: 1
                                                    )
                                            )
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: – Hydration
                sectionCard(title: "💧 HIDRATACIÓN") {
                    VStack(spacing: 16) {
                        // Water drops visual
                        HStack(spacing: 6) {
                            ForEach(0..<10, id: \.self) { drop in
                                let filled = Double(drop) * 0.25 < viewModel.waterLiters
                                Text("💧")
                                    .font(.title3)
                                    .opacity(filled ? 1.0 : 0.2)
                            }
                        }

                        Text(String(format: "%.1f L / %.1f L", viewModel.waterLiters, Config.defaultWaterTargetLiters))
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(Color.hbInk)

                        HStack(spacing: 12) {
                            Button { viewModel.addWater(0.25) } label: {
                                Text("+ 250ml")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.hbSage.opacity(0.12))
                                    .foregroundStyle(Color.hbSage)
                                    .cornerRadius(8)
                            }
                            Button { viewModel.addWater(0.5) } label: {
                                Text("+ 500ml")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.hbSage.opacity(0.12))
                                    .foregroundStyle(Color.hbSage)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // MARK: – Movement
                sectionCard(title: "🚶 MOVIMIENTO") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Pasos")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            Text("\(viewModel.steps.formatted())")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(Color.hbInk)
                        }

                        HStack {
                            Text("¿Entrenaste hoy?")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            HStack(spacing: 8) {
                                togglePill("Sí", selected: viewModel.trainingDone) { viewModel.trainingDone = true }
                                togglePill("No", selected: !viewModel.trainingDone) { viewModel.trainingDone = false }
                            }
                        }

                        if viewModel.trainingDone {
                            TextField("Notas del entrenamiento...", text: $viewModel.trainingNotes, axis: .vertical)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.hbVanilla)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hbLine, lineWidth: 1))
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                // MARK: – Food
                sectionCard(title: "🍽 ALIMENTACIÓN") {
                    VStack(spacing: 16) {
                        HStack {
                            Text("Comidas del plan seguidas")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            Text("\(viewModel.mealsFollowed)/\(viewModel.mealsTotal)")
                                .font(.system(.body, design: .monospaced))
                                .foregroundStyle(Color.hbSage)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Antojos")
                                .font(.caption)
                                .foregroundStyle(Color.hbMuted)
                            TextField("¿Algún antojo hoy?", text: $viewModel.cravings)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.hbVanilla)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hbLine, lineWidth: 1))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Síntomas")
                                .font(.caption)
                                .foregroundStyle(Color.hbMuted)
                            TextField("¿Alguna molestia?", text: $viewModel.symptoms)
                                .font(.subheadline)
                                .padding(12)
                                .background(Color.hbVanilla)
                                .cornerRadius(8)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hbLine, lineWidth: 1))
                        }
                    }
                }

                // MARK: – Free Text
                sectionCard(title: "📝 DIARIO LIBRE") {
                    TextEditor(text: $viewModel.freeText)
                        .font(.subheadline)
                        .foregroundStyle(Color.hbInk)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color.hbVanilla)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hbLine, lineWidth: 1))
                }

                // MARK: – Highlight
                sectionCard(title: "⭐ LO MEJOR DEL DÍA") {
                    TextField("Una frase que resuma lo mejor de hoy", text: $viewModel.highlight)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color.hbVanilla)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.hbLine, lineWidth: 1))
                }

                // MARK: – Save Button
                Button {
                    Task { await viewModel.saveEntry() }
                } label: {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView().tint(.white)
                        }
                        Image(systemName: viewModel.isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                        Text(viewModel.isSaved ? "¡Guardado!" : "Guardar diario")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(viewModel.isSaved ? Color.hbSage.opacity(0.8) : Color.hbSage)
                    .foregroundStyle(.white)
                    .cornerRadius(14)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)

                Spacer().frame(height: 20)
            }
            .padding(.top)
        }
        .background(Color.hbVanilla)
        .task {
            await viewModel.loadEntry(userId: userId)
        }
    }

    // MARK: – Components

    private func sectionCard(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hbSage)
                .tracking(2)
            content()
        }
        .padding(18)
        .background(Color.hbPaper)
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.hbLine, lineWidth: 1))
        .padding(.horizontal)
    }

    private func togglePill(_ label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selected ? Color.hbSage.opacity(0.15) : Color.hbVanilla)
                .foregroundStyle(selected ? Color.hbSage : Color.hbMuted)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(selected ? Color.hbSage : Color.hbLine, lineWidth: 1)
                )
        }
    }

    // MARK: – Data

    private let moodOptions: [(symbol: String, label: String, value: String)] = [
        ("😊", "Genial", "great"),
        ("🙂", "Bien", "good"),
        ("😐", "Normal", "neutral"),
        ("😕", "Mal", "bad"),
        ("😞", "Fatal", "terrible")
    ]

    private let sleepQualities: [(label: String, value: String)] = [
        ("😊 Buena", "great"),
        ("🙂 OK", "good"),
        ("😐 Regular", "fair"),
        ("😕 Mala", "poor")
    ]
}
