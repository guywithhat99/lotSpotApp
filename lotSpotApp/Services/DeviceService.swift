import Foundation
import Combine
import FirebaseDatabase

class DeviceService: ObservableObject {
    @Published var devices: [Device] = []

    private var observer: DatabaseHandle?
    private let ref = Database.database().reference().child("devices")

    func startObserving() {
        guard observer == nil else { return }
        observer = ref.observe(.value) { [weak self] snapshot in
            guard let self else { return }
            let raw = snapshot.value as? [String: Any] ?? [:]
            Task { @MainActor in
                self.devices = DeviceService.parse(snapshot: raw)
                    .sorted { $0.id < $1.id }
            }
        }
    }

    func stopObserving() {
        if let handle = observer {
            ref.removeObserver(withHandle: handle)
        }
    }

    static func parse(snapshot: [String: Any]) -> [Device] {
        snapshot.compactMap { id, value in
            guard let dict = value as? [String: Any] else { return nil }
            return try? Device(id: id, dict: dict)
        }
    }
}
