import SwiftUI

struct DeviceDetailView: View {
    let device: Device

    var body: some View {
        Form {
            Section("Status") {
                LabeledContent("Status", value: device.status.rawValue.capitalized)
                LabeledContent("Lot", value: device.lotId)
            }
            Section("Hardware") {
                LabeledContent("Signal", value: "\(device.signalStrength) dBm")
                LabeledContent("Firmware", value: device.firmwareVersion)
                LabeledContent("Last Seen", value: lastSeenText)
            }
        }
        .navigationTitle(device.id)
    }

    private var lastSeenText: String {
        guard device.lastSeen > 0 else { return "Never" }
        let date = Date(timeIntervalSince1970: device.lastSeen)
        return date.formatted(date: .abbreviated, time: .shortened)
    }
}
