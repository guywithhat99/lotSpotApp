import SwiftUI
import CoreBluetooth

struct BLEScanStepView: View {
    @EnvironmentObject var ble: BLEService
    let onSelect: (CBPeripheral) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Scan for Devices", systemImage: "antenna.radiowaves.left.and.right")
                .font(.headline)

            if ble.isScanning {
                HStack {
                    ProgressView()
                    Text("Scanning…")
                        .foregroundStyle(.secondary)
                }
            }

            if ble.discoveredPeripherals.isEmpty && !ble.isScanning {
                Text("No LotSpot devices found. Make sure device is in provisioning mode.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(ble.discoveredPeripherals, id: \.identifier) { peripheral in
                Button {
                    ble.stopScanning()
                    onSelect(peripheral)
                } label: {
                    HStack {
                        Image(systemName: "cpu")
                        Text(peripheral.name ?? peripheral.identifier.uuidString)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.bordered)
            }

            Spacer()

            Button(ble.isScanning ? "Stop Scanning" : "Start Scanning") {
                if ble.isScanning { ble.stopScanning() }
                else { ble.startScanning() }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear { ble.startScanning() }
        .onDisappear { ble.stopScanning() }
    }
}
