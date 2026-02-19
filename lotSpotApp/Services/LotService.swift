import Foundation
import Combine
import FirebaseDatabase

class LotService: ObservableObject {
    @Published var lots: [Lot] = []
    @Published var isConnected: Bool = true
    @Published var lastUpdated: Date?

    private var observer: DatabaseHandle?
    private let ref = Database.database().reference().child("lots")

    func startObserving() {
        guard observer == nil else { return }
        observer = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            let raw = snapshot.value as? [String: Any] ?? [:]
            Task { @MainActor in
                self.lots = LotService.parse(snapshot: raw)
                    .sorted { $0.name < $1.name }
                self.lastUpdated = Date()
            }
        }
    }

    func stopObserving() {
        if let handle = observer {
            ref.removeObserver(withHandle: handle)
        }
    }

    func setOccupancy(lotId: String, count: Int) async throws {
        let lotRef = Database.database().reference().child("lots/\(lotId)")
        try await lotRef.updateChildValues([
            "occupancy": count,
            "manual_override": true
        ])
    }

    func setStatus(lotId: String, status: LotStatus) async throws {
        let lotRef = Database.database().reference().child("lots/\(lotId)")
        try await lotRef.updateChildValues(["status": status.rawValue])
    }

    static func parse(snapshot: [String: Any]) -> [Lot] {
        snapshot.compactMap { id, value in
            guard let dict = value as? [String: Any] else { return nil }
            return try? Lot(id: id, dict: dict)
        }
    }
}
