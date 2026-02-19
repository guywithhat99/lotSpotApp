import Foundation

enum LotStatus: String {
    case open
    case closed
}

struct Lot: Identifiable {
    let id: String
    var name: String
    var capacity: Int
    var occupancy: Int
    var totalEntries: Int
    var totalExits: Int
    var status: LotStatus
    var manualOverride: Bool
    var lastUpdated: TimeInterval

    init(id: String, dict: [String: Any]) throws {
        guard let name = dict["name"] as? String else {
            throw LotError.missingField("name")
        }
        self.id = id
        self.name = name
        self.capacity = dict["capacity"] as? Int ?? 0
        self.occupancy = dict["occupancy"] as? Int ?? 0
        self.totalEntries = dict["total_entries"] as? Int ?? 0
        self.totalExits = dict["total_exits"] as? Int ?? 0
        self.status = LotStatus(rawValue: dict["status"] as? String ?? "open") ?? .open
        self.manualOverride = dict["manual_override"] as? Bool ?? false
        self.lastUpdated = dict["last_updated"] as? TimeInterval ?? 0
    }

    var available: Int { max(0, capacity - occupancy) }
    var isFull: Bool { occupancy >= capacity }
    var fillFraction: Double { capacity > 0 ? Double(occupancy) / Double(capacity) : 0 }
}

enum LotError: Error {
    case missingField(String)
}
