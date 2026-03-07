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
