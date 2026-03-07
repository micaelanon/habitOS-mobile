import Foundation
import AVFoundation

/// State machine for the food scanner
enum ScannerState: Equatable {
    case scanning
    case loading(barcode: String)
    case found(product: OpenFoodFactsProduct)
    case notFound
    case error(message: String)
}

@Observable
final class FoodScannerViewModel: NSObject {
    var state: ScannerState = .scanning
    var lastScannedBarcode: String?

    // AVFoundation objects must be managed on a background queue
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.habitos.scanner.sessionQueue")
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: – Setup

    func setup() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            guard self.captureSession.inputs.isEmpty else { return }
            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.addInput(input)

            let output = AVCaptureMetadataOutput()
            self.captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.ean13, .ean8, .upce, .qr]

            self.captureSession.commitConfiguration()

            DispatchQueue.main.async {
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewLayer?.videoGravity = .resizeAspectFill
            }
        }
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self = self, !self.captureSession.isRunning else { return }
            self.captureSession.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
        }
    }

    // MARK: – Lookup

    func lookup(barcode: String) async {
        guard barcode != lastScannedBarcode else { return }
        lastScannedBarcode = barcode
        state = .loading(barcode: barcode)

        do {
            if let product = try await OpenFoodFactsService.shared.lookup(barcode: barcode) {
                state = .found(product: product)
            } else {
                state = .notFound
            }
        } catch {
            state = .error(message: error.localizedDescription)
        }
    }

    func reset() {
        lastScannedBarcode = nil
        state = .scanning
    }
}

// MARK: – AVCaptureMetadataOutputObjectsDelegate

extension FoodScannerViewModel: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard state == .scanning,
              let metadataObject = metadataObjects.first,
              let readable = metadataObject as? AVMetadataMachineReadableCodeObject,
              let barcode = readable.stringValue else { return }

        Task { @MainActor in await self.lookup(barcode: barcode) }
    }
}
