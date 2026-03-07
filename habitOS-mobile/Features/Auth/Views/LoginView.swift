import SwiftUI

/// Login / Welcome screen — habitOS branding
struct LoginView: View {
    @State private var viewModel = AuthViewModel()
    var onAuthenticated: (AppUser) -> Void

    var body: some View {
        ZStack {
            Color.hbVanilla.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    Spacer().frame(height: 60)

                    // Logo
                    VStack(spacing: 12) {
                        HBLogoView(size: 48)
                        Text("habitOS")
                            .font(.custom("Georgia", size: 36, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.hbInk)
                        Text("Tu plan nutricional, siempre contigo")
                            .font(.subheadline)
                            .foregroundStyle(Color.hbInk.opacity(0.6))
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EMAIL")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.hbSage)
                            .tracking(2)

                        TextField("tu@email.com", text: $viewModel.email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding(14)
                            .background(Color.hbPaper)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.hbLine, lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 32)

                    // Password field (if toggled)
                    if viewModel.showPasswordLogin {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CONTRASEÑA")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.hbSage)
                                .tracking(2)

                            SecureField("••••••••", text: $viewModel.password)
                                .textContentType(.password)
                                .padding(14)
                                .background(Color.hbPaper)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.hbLine, lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 32)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Error message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 32)
                    }

                    // Magic link sent confirmation
                    if viewModel.magicLinkSent {
                        VStack(spacing: 8) {
                            Image(systemName: "envelope.badge.fill")
                                .font(.title)
                                .foregroundStyle(Color.hbSage)
                            Text("¡Link enviado!")
                                .font(.headline)
                                .foregroundStyle(Color.hbInk)
                            Text("Revisa tu email y pulsa el enlace para entrar.")
                                .font(.caption)
                                .foregroundStyle(Color.hbInk.opacity(0.6))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.hbSage.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal, 32)
                    }

                    // Buttons
                    VStack(spacing: 14) {
                        if viewModel.showPasswordLogin {
                            Button {
                                Task {
                                    await viewModel.signInWithPassword()
                                    if let user = await viewModel.checkSession() {
                                        onAuthenticated(user)
                                    }
                                }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    }
                                    Text("Iniciar sesión")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.hbSage)
                                .foregroundStyle(.white)
                                .cornerRadius(14)
                            }
                            .disabled(viewModel.isLoading)
                        } else {
                            Button {
                                Task { await viewModel.signInWithMagicLink() }
                            } label: {
                                HStack {
                                    if viewModel.isLoading {
                                        ProgressView().tint(.white)
                                    }
                                    Text("Entrar con mi email")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.hbSage)
                                .foregroundStyle(.white)
                                .cornerRadius(14)
                            }
                            .disabled(viewModel.isLoading)
                        }

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.showPasswordLogin.toggle()
                            }
                        } label: {
                            Text(viewModel.showPasswordLogin ? "Usar magic link" : "Usar contraseña")
                                .font(.subheadline)
                                .foregroundStyle(Color.hbSage)
                        }
                    }
                    .padding(.horizontal, 32)

                    // MARK: – Demo Mode Divider
                    HStack(spacing: 12) {
                        Rectangle().fill(Color.hbLine).frame(height: 1)
                        Text("o")
                            .font(.caption)
                            .foregroundStyle(Color.hbMuted)
                        Rectangle().fill(Color.hbLine).frame(height: 1)
                    }
                    .padding(.horizontal, 32)

                    // Demo Mode Button
                    Button {
                        onAuthenticated(AppUser.demoUser)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                            Text("Entrar en modo demo")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.hbInk.opacity(0.06))
                        .foregroundStyle(Color.hbInk.opacity(0.7))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.hbLine, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 32)

                    // Footer
                    Text("¿No tienes cuenta? Habla con tu nutricionista")
                        .font(.caption)
                        .foregroundStyle(Color.hbInk.opacity(0.4))

                    Spacer().frame(height: 40)
                }
            }
        }
    }
}

// MARK: – Demo User Factory

extension AppUser {
    /// Mock user for development/demo mode
    static let demoUser = AppUser(
        id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        authUserId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        coachProfileId: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
        firstName: "Micael",
        lastName: "García",
        email: "micaelanon@gmail.com",
        phone: nil,
        avatarUrl: nil,
        sex: "male",
        dateOfBirth: nil,
        heightCm: 168,
        currentWeightKg: 81.2,
        goal: "Perder grasa, ganar energía",
        activityLevel: "moderate",
        foodAllergies: [],
        foodDislikes: [],
        dietType: "balanced",
        medicalConditions: [],
        timezone: "Europe/Madrid",
        locale: "es",
        notificationsEnabled: true,
        healthkitEnabled: false,
        onboardingCompleted: true,
        createdAt: Date(),
        updatedAt: Date()
    )
}
