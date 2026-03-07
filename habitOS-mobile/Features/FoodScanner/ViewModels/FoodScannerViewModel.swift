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

    // AVFoundation objects must be on a background queue
    private let captureSession = AVCaptureSession()
    private(set) var previewLayer: AVCaptureVideoPreviewLayer?

    // MARK: – Setup

    func setup() {
        guard captureSession.inputs.isEmpty else { return }
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }

        captureSession.beginConfiguration()
        captureSession.addInput(input)

        let output = AVCaptureMetadataOutput()
        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.ean13, .ean8, .upce, .qr]

        captureSession.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }

    func start() {
        guard !captureSession.isRunning else { return }
        Task.detached { [weak self] in await self?.captureSession.startRunning() }
    }

    func stop() {
        guard captureSession.isRunning else { return }
        Task.detached { [weak self] in await self?.captureSession.stopRunning() }
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

        Task { await lookup(barcode: barcode) }
    }
}
