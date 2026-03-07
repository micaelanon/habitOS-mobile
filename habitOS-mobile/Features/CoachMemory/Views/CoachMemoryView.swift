import SwiftUI

/// Shows the facts that the AI coach remembers about the user
struct CoachMemoryView: View {
    @State private var viewModel = CoachMemoryViewModel()
    let userId: UUID?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {

                // Intro header
                HBCard {
                    HStack(spacing: 14) {
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 26))
                            .foregroundStyle(Color.hbSage)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Memoria del Coach")
                                .font(.hbSerifBold(18))
                                .foregroundStyle(Color.hbInk)
                            Text("Tu coach recuerda estos datos para personalizar tus planes y recomendaciones.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.hbMuted)
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 40)
                } else if viewModel.groupedMemories.isEmpty {
                    emptyState
                } else {
                    ForEach(viewModel.groupedMemories, id: \.category) { group in
                        categorySection(group)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
        .navigationTitle("Memoria del Coach")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.hbVanilla.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            if let uid = userId {
                await viewModel.load(userId: uid)
            } else {
                viewModel.memories = CoachMemoryViewModel.demo
            }
        }
    }

    // MARK: – Category section

    private func categorySection(_ group: (category: String, icon: String, items: [CoachMemory])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: group.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.hbSage)
                Text(group.category.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(Color.hbSage)
                Spacer()
                Text("\(group.items.count) dato\(group.items.count == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hbMuted2)
            }

            HBCard {
                VStack(spacing: 0) {
                    ForEach(Array(group.items.enumerated()), id: \.element.id) { idx, memory in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.hbSage.opacity(0.25))
                                .frame(width: 7, height: 7)
                            Text(memory.fact)
                                .font(.system(size: 14))
                                .foregroundStyle(Color.hbInk)
                            Spacer()
                            Text(memory.createdAt, format: .dateTime.day().month())
                                .font(.system(size: 10))
                                .foregroundStyle(Color.hbMuted2)
                            Button {
                                viewModel.forget(memory: memory)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(Color.hbMuted2)
                                    .padding(6)
                            }
                        }
                        .padding(.vertical, 10)
                        if idx < group.items.count - 1 {
                            HBDivider()
                        }
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain")
                .font(.system(size: 48))
                .foregroundStyle(Color.hbSage.opacity(0.4))
            Text("Aún sin recuerdos")
                .font(.hbSerifBold(20))
                .foregroundStyle(Color.hbInk)
            Text("Tu coach irá guardando datos relevantes a medida que interactúes con él.")
                .font(.system(size: 13))
                .foregroundStyle(Color.hbMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }
}
