import SwiftUI

/// Onboarding — 3 slides, shown only on first launch
struct OnboardingView: View {
    @State private var currentSlide = 0
    var onComplete: () -> Void

    private let slides: [(icon: String, title: String, description: String)] = [
        ("fork.knife", "Tu dieta, día a día", "Sigue tu plan nutricional personalizado con recetas, macros e ingredientes detallados."),
        ("message.fill", "Habla con tu coach", "Chat en tiempo real con tu nutricionista. Pregunta, comparte y recibe apoyo directo."),
        ("chart.line.uptrend.xyaxis", "Ve tu progreso", "Gráficas de peso, adherencia y hábitos para ver tu evolución semana a semana.")
    ]

    var body: some View {
        ZStack {
            Color.hbVanilla.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Slide content
                TabView(selection: $currentSlide) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(spacing: 28) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(Color.hbSage.opacity(0.12))
                                    .frame(width: 120, height: 120)
                                Image(systemName: slides[index].icon)
                                    .font(.system(size: 44))
                                    .foregroundStyle(Color.hbSage)
                            }

                            // Title
                            Text(slides[index].title)
                                .font(.custom("Georgia", size: 26, relativeTo: .title))
                                .fontWeight(.bold)
                                .foregroundStyle(Color.hbInk)

                            // Description
                            Text(slides[index].description)
                                .font(.body)
                                .foregroundStyle(Color.hbInk.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // Dots indicator
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentSlide ? Color.hbSage : Color.hbLine)
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.2), value: currentSlide)
                    }
                }
                .padding(.bottom, 32)

                // Button
                Button {
                    if currentSlide < slides.count - 1 {
                        withAnimation { currentSlide += 1 }
                    } else {
                        onComplete()
                    }
                } label: {
                    Text(currentSlide == slides.count - 1 ? "Empezar" : "Siguiente")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.hbSage)
                        .foregroundStyle(.white)
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)

                // Skip
                if currentSlide < slides.count - 1 {
                    Button {
                        onComplete()
                    } label: {
                        Text("Saltar")
                            .font(.subheadline)
                            .foregroundStyle(Color.hbInk.opacity(0.4))
                    }
                    .padding(.top, 12)
                }

                Spacer().frame(height: 40)
            }
        }
    }
}
