import Foundation

enum DeviceStatus: String {
    case online
    case offline
}

struct Device: Identifiable {
    let id: String
    var lotId: String
    var status: DeviceStatus
    var lastSeen: TimeInterval
    var signalStrength: Int
    var firmwareVersion: String

    init(id: String, dict: [String: Any]) throws {
        self.id = id
        self.lotId = dict["lot_id"] as? String ?? ""
        self.status = DeviceStatus(rawValue: dict["status"] as? String ?? "") ?? .offline
        self.lastSeen = dict["last_seen"] as? TimeInterval ?? 0
        self.signalStrength = dict["signal_strength"] as? Int ?? 0
        self.firmwareVersion = dict["firmware_version"] as? String ?? "unknown"
    }
}
