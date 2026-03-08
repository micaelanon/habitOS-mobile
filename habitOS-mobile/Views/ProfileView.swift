import SwiftUI
import PhotosUI

struct ProfileView: View {
    let user: AppUser?
    let coachName: String
    @State private var viewModel = SettingsViewModel()
    @Environment(AppState.self) private var appState
    @State private var showScanner = false
    @State private var healthStore = HealthKitManager.shared
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: UIImage?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: HBTokens.sectionGap) {

                // ── Header ──
                VStack(spacing: 16) {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        ZStack(alignment: .bottomTrailing) {
                            if let avatarImage {
                                Image(uiImage: avatarImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.hbSageBg)
                                        .frame(width: 80, height: 80)
                                    Text(String(user?.firstName.prefix(1) ?? "?"))
                                        .font(.hbSerifBold(32))
                                        .foregroundStyle(Color.hbSage)
                                }
                            }
                            Circle()
                                .fill(Color.hbSage)
                                .frame(width: 26, height: 26)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.hbVanilla)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        }
                    }
                    .onChange(of: selectedItem) { _, newItem in
                        Task { await loadAndSaveAvatar(from: newItem) }
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
                        if appState.accountMode == .coachConnected {
                            HBDivider()
                            infoRow("Nutricionista", value: coachName)
                        }
                    }
                }
                .staggered(index: 2)

                // ── Settings ──
                HBCard {
                    VStack(spacing: 0) {
                        HBSectionHeader("Ajustes", icon: "gearshape")
                            .padding(.bottom, 14)

                        toggleRow(icon: "bell", label: "Notificaciones", isOn: $viewModel.isNotificationsEnabled)
                            .onChange(of: viewModel.isNotificationsEnabled) { _, isEnabled in
                                if isEnabled {
                                    Task { _ = await NotificationManager.shared.requestPermission() }
                                } else {
                                    NotificationManager.shared.cancelAll()
                                }
                            }
                        HBDivider(indent: 44)
                        toggleRow(icon: "heart", label: "Apple Health", isOn: $viewModel.isHealthKitEnabled)
                            .onChange(of: viewModel.isHealthKitEnabled) { _, isEnabled in
                                if isEnabled {
                                    Task { await HealthKitManager.shared.requestAuthorization() }
                                }
                            }
                        HBDivider(indent: 44)
                        Button { showScanner = true } label: {
                            navRowLabel(icon: "barcode.viewfinder", label: "Escáner de alimentos")
                        }
                        .buttonStyle(.plain)
                        HBDivider(indent: 44)
                        NavigationLink(destination: CoachMemoryView(userId: appState.currentUser?.id, accountMode: appState.accountMode)) {
                            navRowLabel(icon: "brain.head.profile", label: appState.accountMode == .coachConnected ? "Memoria del coach" : "Lo que habitOS sabe de ti")
                        }
                        HBDivider(indent: 44)
                        NavigationLink(destination: placeholderView(title: "Privacidad", icon: "lock.shield", body: "Tu información está protegida. HabitOS no comparte tus datos con terceros.")) {
                            navRowLabel(icon: "lock.shield", label: "Privacidad")
                        }
                        HBDivider(indent: 44)
                        NavigationLink(destination: placeholderView(title: "Ayuda", icon: "questionmark.circle", body: "¿Necesitas ayuda? Escríbenos desde el chat o a soporte@habitos.app.")) {
                            navRowLabel(icon: "questionmark.circle", label: "Ayuda")
                        }
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
                .alert("Error de HealthKit", isPresented: Binding(
                    get: { healthStore.errorMessage != nil },
                    set: { if !$0 { healthStore.errorMessage = nil } }
                )) {
                    Button("Entendido") { healthStore.errorMessage = nil }
                } message: {
                    Text(healthStore.errorMessage ?? "")
                }

                Spacer(minLength: 32)
            }
            .padding(.horizontal, HBTokens.padScreen)
            .padding(.top, 8)
        }
        .background(Color.hbVanilla)
        .onAppear { avatarImage = Self.loadAvatarFromDisk() }
    }

    // MARK: – Avatar Helpers

    private static var avatarFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("habitos_avatar.jpg")
    }

    private static func loadAvatarFromDisk() -> UIImage? {
        guard FileManager.default.fileExists(atPath: avatarFileURL.path) else { return nil }
        return UIImage(contentsOfFile: avatarFileURL.path)
    }

    private func loadAndSaveAvatar(from item: PhotosPickerItem?) async {
        guard let item,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }

        // Downscale to 400px max for avatar
        let maxDim: CGFloat = 400
        let size = image.size
        let resized: UIImage
        if max(size.width, size.height) > maxDim {
            let scale = maxDim / max(size.width, size.height)
            let newSize = CGSize(width: size.width * scale, height: size.height * scale)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        } else {
            resized = image
        }

        if let jpegData = resized.jpegData(compressionQuality: 0.85) {
            try? jpegData.write(to: Self.avatarFileURL)
        }
        avatarImage = resized
    }

    private func placeholderView(title: String, icon: String, body: String) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.hbSage)
                Text(body)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.hbMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        }
        .background(Color.hbVanilla)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
