import Foundation
import Network

/// Monitors network connectivity for offline-first behavior
@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()

    var isConnected: Bool = true
    var connectionType: NWInterface.InterfaceType?

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }

    deinit { monitor.cancel() }
}
