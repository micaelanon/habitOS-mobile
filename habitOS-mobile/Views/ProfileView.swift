import SwiftUI

struct ProfileView: View {
    let user: UserProfile?
    @State private var viewModel = SettingsViewModel()
    @Environment(AppState.self) private var appState
    @State private var showScanner = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HBTokens.sectionGap) {

                // ── Header ──
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.hbSageBg)
                            .frame(width: 80, height: 80)
                        Text(String(user?.firstName.prefix(1) ?? "?"))
                            .font(.hbSerifBold(32))
                            .foregroundStyle(Color.hbSage)
                    }

                    VStack(spacing: 6) {
                        Text("\(user?.firstName ?? "") \(user?.lastName ?? "")")
                            .font(.hbSerifBold(24))
                            .foregroundStyle(Color.hbInk)
                        if let goal = user?.goal {
                            HBBadge(text: goal, style: .accent)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .staggered(index: 0)

                // ── Stats ──
                HStack(spacing: 12) {
                    statCard("Peso", value: user?.currentWeightKg.map { String(format: "%.1f", $0) } ?? "–", unit: "kg")
                    statCard("Altura", value: user?.heightCm.map { String(format: "%.0f", $0) } ?? "–", unit: "cm")
                    statCard("Objetivo", value: user?.targetWeightKg.map { String(format: "%.1f", $0) } ?? "–", unit: "kg")
                }
                .staggered(index: 1)

                // ── Info ──
                HBCard {
                    VStack(spacing: 14) {
                        HBSectionHeader("Información", icon: "person")
                        infoRow("Correo", value: user?.email ?? "–")
                        HBDivider()
                        infoRow("Coach", value: user?.coachName ?? "–")
                    }
                }
                .staggered(index: 2)

                // ── Settings ──
                HBCard {
                    VStack(spacing: 0) {
                        HBSectionHeader("Ajustes", icon: "gearshape")
                            .padding(.bottom, 14)

                        toggleRow(icon: "bell", label: "Notificaciones", isOn: $viewModel.isNotificationsEnabled)
                        HBDivider(indent: 44)
                        toggleRow(icon: "heart", label: "Apple Health", isOn: $viewModel.isHealthKitEnabled)
                        HBDivider(indent: 44)
                        Button { showScanner = true } label: {
                            navRowLabel(icon: "barcode.viewfinder", label: "Escáner de alimentos")
                        }
                        .buttonStyle(.plain)
                        HBDivider(indent: 44)
                        NavigationLink(destination: CoachMemoryView(userId: appState.currentUser?.id)) {
                            navRowLabel(icon: "brain.head.profile", label: "Memoria del coach")
                        }
                        HBDivider(indent: 44)
                        navRow(icon: "lock.shield", label: "Privacidad")
                        HBDivider(indent: 44)
                        navRow(icon: "questionmark.circle", label: "Ayuda")
                    }
                }
                .staggered(index: 3)

                // ── Version ──
                HBLogoView(size: 16)
                    .frame(maxWidth: .infinity)
                    .staggered(index: 4)

                Text("v1.0.0")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hbMuted2)
                    .frame(maxWidth: .infinity)

                // ── Logout ──
                Button {
                    viewModel.showLogoutConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Cerrar sesión")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.hbInk.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 46)
                    .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: HBTokens.radiusMedium))
                    .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusMedium).stroke(Color.hbLine, lineWidth: 1))
                }
                .disabled(viewModel.isAttemptingLogout)
                .opacity(viewModel.isAttemptingLogout ? 0.5 : 1.0)
                .confirmationDialog("¿Seguro que quieres cerrar sesión?", isPresented: $viewModel.showLogoutConfirm, titleVisibility: .visible) {
                    Button("Cerrar sesión", role: .destructive) {
                        Task { await viewModel.logout(appState: appState) }
                    }
                    Button("Cancelar", role: .cancel) {}
                }
                .staggered(index: 5)
                .fullScreenCover(isPresented: $showScanner) {
                    BarcodeScannerView()
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
    }

    private func statCard(_ label: String, value: String, unit: String) -> some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.hbInk)
                Text(unit).font(.system(size: 10)).foregroundStyle(Color.hbMuted2)
            }
            Text(label.uppercased())
                .font(.hbKicker(9))
                .tracking(2)
                .foregroundStyle(Color.hbSage)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.hbPaper, in: RoundedRectangle(cornerRadius: HBTokens.radiusLarge))
        .overlay(RoundedRectangle(cornerRadius: HBTokens.radiusLarge).stroke(Color.hbLine, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 12, y: 4)
    }

    private func infoRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 12, weight: .medium)).foregroundStyle(Color.hbMuted2)
            Spacer()
            Text(value).font(.system(size: 14)).foregroundStyle(Color.hbInk)
        }
    }

    private func navRow(icon: String, label: String) -> some View {
        Button {} label: { navRowLabel(icon: icon, label: label) }.buttonStyle(.plain)
    }

    private func navRowLabel(icon: String, label: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hbSage)
                .frame(width: 30, height: 30)
                .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: 8))
            Text(label).font(.system(size: 14)).foregroundStyle(Color.hbInk)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .medium)).foregroundStyle(Color.hbMuted2)
        }
        .padding(.vertical, 10)
    }

    private func toggleRow(icon: String, label: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.hbSage)
                .frame(width: 30, height: 30)
                .background(Color.hbSageBg, in: RoundedRectangle(cornerRadius: 8))
            Toggle(label, isOn: isOn)
                .font(.system(size: 14))
                .foregroundStyle(Color.hbInk)
                .tint(Color.hbSage)
        }
        .padding(.vertical, 6)
    }
}
