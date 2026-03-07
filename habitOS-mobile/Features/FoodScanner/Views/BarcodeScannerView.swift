import SwiftUI
import AVFoundation

/// Full-screen barcode camera scanner with product result overlay
struct BarcodeScannerView: View {
    @State private var viewModel = FoodScannerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Camera preview
            CameraPreviewView(viewModel: viewModel)
                .ignoresSafeArea()

            // Scanner frame overlay
            scannerOverlay

            // Top bar
            VStack {
                HStack {
                    Button {
                        viewModel.stop()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.85))
                            .background(Color.black.opacity(0.3), in: Circle())
                    }
                    Spacer()
                    Text("ESCANEAR")
                        .font(.system(size: 13, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(.white)
                    Spacer()
                    // Balance spacer
                    Color.clear.frame(width: 28, height: 28)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)

                Spacer()

                // Status area / result card
                resultArea
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            viewModel.setup()
            viewModel.start()
        }
        .onDisappear { viewModel.stop() }
    }

    // MARK: – Scanner frame

    private var scannerOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width * 0.72
            let h = w * 0.62
            let x = (geo.size.width - w) / 2
            let y = (geo.size.height - h) / 2 - 60

            ZStack {
                // Dark vignette outside the frame
                Color.black.opacity(0.52)
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(width: w, height: h)
                                    .blendMode(.destinationOut)
                            )
                    )

                // Frame corners
                CornerFrameShape(size: 22, lineWidth: 3, cornerRadius: 16)
                    .stroke(Color.hbSage, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: w, height: h)
                    .offset(x: x - geo.size.width / 2 + w / 2,
                            y: y - geo.size.height / 2 + h / 2)

                // Scanning hint
                Text("Apunta al código de barras")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
                    .offset(x: 0, y: y - geo.size.height / 2 + h / 2 + h / 2 + 14)
            }
        }
    }

    // MARK: – Result area

    @ViewBuilder
    private var resultArea: some View {
        switch viewModel.state {
        case .scanning:
            EmptyView()

        case .loading(let barcode):
            HStack(spacing: 12) {
                ProgressView().tint(.white)
                Text("Buscando \(barcode)…")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 24)

        case .found(let product):
            FoodProductCard(product: product) {
                viewModel.reset()
            }
            .padding(.horizontal, 16)
            .transition(.move(edge: .bottom).combined(with: .opacity))

        case .notFound:
            notFoundBanner

        case .error(let msg):
            errorBanner(msg)
        }
    }

    private var notFoundBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Producto no encontrado")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Text("Intenta con otro código")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.7))
            }
            Spacer()
            Button("Reiniciar") { viewModel.reset() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.hbSage)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
    }

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "wifi.slash").foregroundStyle(.red)
            Text(msg)
                .font(.system(size: 13))
                .foregroundStyle(.white)
                .lineLimit(2)
            Spacer()
            Button("Reiniciar") { viewModel.reset() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.hbSage)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 24)
    }
}

// MARK: – Camera preview UIViewRepresentable

struct CameraPreviewView: UIViewRepresentable {
    let viewModel: FoodScannerViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black

        if let layer = viewModel.previewLayer {
            layer.frame = UIScreen.main.bounds
            view.layer.addSublayer(layer)
        }
        
#if targetEnvironment(simulator)
        let label = UILabel()
        label.text = "Cámara no disponible en el Simulador.\nToca aquí para simular un escaneo."
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.simulateScan))
        view.addGestureRecognizer(tap)
#endif
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        viewModel.previewLayer?.frame = uiView.bounds
    }
    
#if targetEnvironment(simulator)
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject {
        let viewModel: FoodScannerViewModel
        
        init(viewModel: FoodScannerViewModel) {
            self.viewModel = viewModel
        }
        
        @objc func simulateScan() {
            // Coca-Cola Zero barcode for demo
            let demoBarcode = "5449000131805"
            Task { @MainActor in await viewModel.lookup(barcode: demoBarcode) }
        }
    }
#endif
}

// MARK: – Corner frame shape

struct CornerFrameShape: Shape {
    let size: CGFloat
    let lineWidth: CGFloat
    let cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let s = size
        let r = cornerRadius

        // Top-left
        p.move(to: CGPoint(x: rect.minX + r, y: rect.minY + s))
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.minY + r))
        p.addQuadCurve(to: CGPoint(x: rect.minX + s, y: rect.minY),
                       control: CGPoint(x: rect.minX, y: rect.minY))

        // Top-right
        p.move(to: CGPoint(x: rect.maxX - s, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + s),
                       control: CGPoint(x: rect.maxX, y: rect.minY))

        // Bottom-right
        p.move(to: CGPoint(x: rect.maxX, y: rect.maxY - s))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - s, y: rect.maxY),
                       control: CGPoint(x: rect.maxX, y: rect.maxY))

        // Bottom-left
        p.move(to: CGPoint(x: rect.minX + s, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - s),
                       control: CGPoint(x: rect.minX, y: rect.maxY))

        return p
    }
}
