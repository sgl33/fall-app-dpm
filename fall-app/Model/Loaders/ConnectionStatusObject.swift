import Foundation

/// Status of the connection between the sensor and the iPhone.
///
/// ### Author & Version
/// Seung-Gu Lee (seunggu@umich.edu), last modified May 23, 2023
///
class ConnectionStatusObject: ObservableObject {
    
    @Published var status: ConnectionStatus = ConnectionStatus.notConnected;
    @Published var conn: Bool = false // connected

    func setStatus(status: ConnectionStatus) {
        self.status = status
        conn = connected()
    }
    
    func getStatus() -> ConnectionStatus {
        return self.status
    }
    
    func showModal() -> Bool {
        return self.status == ConnectionStatus.scanning ||
            self.status == ConnectionStatus.found
    }
    
    func connected() -> Bool {
        return self.status == ConnectionStatus.connected
    }
}

/// Enum indicating connection status between the sensor and the iPhone.
enum ConnectionStatus {
    case notConnected, scanning, found, disconnecting, connected
}
