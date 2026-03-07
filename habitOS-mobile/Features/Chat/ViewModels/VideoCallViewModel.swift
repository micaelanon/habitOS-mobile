import Foundation
import AVFoundation

enum CallState {
    case idle
    case connecting
    case active
    case ended
}

@Observable
final class VideoCallViewModel: NSObject, @unchecked Sendable {
    var callState: CallState = .idle
    var isMuted = false
    var isVideoOff = false
    var callDuration: TimeInterval = 0
    var errorMessage: String?
    
    // Local Camera
    let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var cameraDevice: AVCaptureDevice?
    
    private var timer: Timer?
    
    override init() {
        super.init()
    }
    
    // MARK: - Call Lifecycle
    
    func startCall() {
        callState = .connecting
        setupCamera()
        
        // Simulate signaling / connection delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            guard let self = self, self.callState != .ended else { return }
            self.callState = .active
            self.startTimer()
        }
    }
    
    func endCall() {
        callState = .ended
        stopTimer()
        stopCamera()
    }
    
    // MARK: - Controls
    
    func toggleMute() {
        isMuted.toggle()
        // Here you would mute the WebRTC / LiveKit audio track
    }
    
    func toggleVideo() {
        isVideoOff.toggle()
        if isVideoOff {
            stopCamera()
        } else {
            startCamera()
        }
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.callDuration += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Camera Setup
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.captureSession.beginConfiguration()
            
            // Look for front camera
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                DispatchQueue.main.async { self.errorMessage = "Cámara frontal no encontrada" }
                self.captureSession.commitConfiguration()
                return
            }
            
            self.cameraDevice = videoDevice
            
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                if self.captureSession.canAddInput(videoDeviceInput) {
                    self.captureSession.addInput(videoDeviceInput)
                }
            } catch {
                DispatchQueue.main.async { self.errorMessage = "No se pudo acceder a la cámara" }
                self.captureSession.commitConfiguration()
                return
            }
            
            self.captureSession.commitConfiguration()
            
            if !self.isVideoOff {
                self.captureSession.startRunning()
            }
        }
    }
    
    private func startCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.captureSession.isRunning == false {
                self?.captureSession.startRunning()
            }
        }
    }
    
    private func stopCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if self?.captureSession.isRunning == true {
                self?.captureSession.stopRunning()
            }
        }
    }
    
    var formattedDuration: String {
        let minutes = Int(callDuration) / 60
        let seconds = Int(callDuration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
