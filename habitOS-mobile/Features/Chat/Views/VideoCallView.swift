import SwiftUI
import AVFoundation

struct VideoCallView: View {
    @State private var viewModel = VideoCallViewModel()
    let coachName: String
    @Environment(\.dismiss) private var dismiss
    
    // PiP Dragging State
    @State private var pipOffset: CGSize = .zero
    @State private var accumulatedOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // MARK: - Remote Video (Coach)
            Color.hbInk.ignoresSafeArea()
            
            if viewModel.callState == .active {
                // Simulate Coach Video (Blurred gradient for premium look)
                LinearGradient(colors: [Color.hbSage.opacity(0.3), Color.hbInk], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("Hablando con")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.hbMuted2)
                    Text(coachName)
                        .font(.hbSerifBold(28))
                        .foregroundStyle(Color.hbVanilla)
                    Text(viewModel.formattedDuration)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundStyle(Color.white)
                        .padding(.top, 4)
                    Spacer().frame(height: 180)
                }
            } else if viewModel.callState == .connecting {
                VStack(spacing: 24) {
                    ProgressView()
                        .tint(Color.hbSage)
                        .scaleEffect(1.5)
                    Text("Conectando con \(coachName)...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.hbVanilla)
                }
            } else if viewModel.callState == .ended {
                VStack(spacing: 16) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.red)
                    Text("Llamada finalizada")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.hbVanilla)
                    Text(viewModel.formattedDuration)
                        .font(.system(size: 16, design: .monospaced))
                        .foregroundStyle(Color.hbMuted2)
                }
            }
            
            // MARK: - Local Video (PiP)
            if viewModel.callState == .active || viewModel.callState == .connecting {
                GeometryReader { geometry in
                    ZStack {
                        if viewModel.isVideoOff {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.hbPaper.opacity(0.1))
                                .overlay(
                                    Image(systemName: "video.slash.fill")
                                        .foregroundStyle(Color.white)
                                )
                        } else {
                            PiPCameraPreview(session: viewModel.captureSession)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .frame(width: 110, height: 160)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                    // Bottom Right alignment initially
                    .position(
                        x: geometry.size.width - 75 + pipOffset.width,
                        y: geometry.size.height - 200 + pipOffset.height
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                pipOffset = CGSize(
                                    width: accumulatedOffset.width + value.translation.width,
                                    height: accumulatedOffset.height + value.translation.height
                                )
                            }
                            .onEnded { value in
                                accumulatedOffset = pipOffset
                            }
                    )
                }
            }
            
            // MARK: - Bottom Controls
            VStack {
                Spacer()
                
                HStack(spacing: 32) {
                    // Mute Audio
                    controlButton(
                        icon: viewModel.isMuted ? "mic.slash.fill" : "mic.fill",
                        color: viewModel.isMuted ? Color.white : Color.hbPaper.opacity(0.2),
                        iconColor: viewModel.isMuted ? Color.hbInk : .white
                    ) {
                        viewModel.toggleMute()
                    }
                    
                    // Toggle Video
                    controlButton(
                        icon: viewModel.isVideoOff ? "video.slash.fill" : "video.fill",
                        color: viewModel.isVideoOff ? Color.white : Color.hbPaper.opacity(0.2),
                        iconColor: viewModel.isVideoOff ? Color.hbInk : .white
                    ) {
                        viewModel.toggleVideo()
                    }
                    
                    // End Call
                    controlButton(
                        icon: "phone.down.fill",
                        color: Color.red,
                        iconColor: .white
                    ) {
                        viewModel.endCall()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 32)
                .background(
                    Capsule()
                        .fill(Color.hbInk.opacity(0.8))
                        .background(Capsule().stroke(Color.hbPaper.opacity(0.1), lineWidth: 1))
                )
                .padding(.bottom, HBTokens.padScreen)
            }
            .opacity(viewModel.callState == .ended ? 0 : 1)
            .animation(.easeInOut, value: viewModel.callState)
        }
        .onAppear {
            viewModel.startCall()
        }
        .onDisappear {
            viewModel.endCall()
        }
    }
    
    private func controlButton(icon: String, color: Color, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 60, height: 60)
                .background(color, in: Circle())
        }
    }
}

// MARK: - Local Camera PiP Renderer
struct PiPCameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.name = "PiP_PreviewLayer"
        view.layer.addSublayer(previewLayer)
        
        #if targetEnvironment(simulator)
        let label = UILabel()
        label.text = "Cámara\n(Simulador)"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        #endif
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first(where: { $0.name == "PiP_PreviewLayer" }) {
            // Need async to let the UIView layout bounds first in SwiftUI
            DispatchQueue.main.async {
                layer.frame = uiView.bounds
            }
        }
    }
}
