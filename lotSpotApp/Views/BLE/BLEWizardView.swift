import SwiftUI
import CoreBluetooth

struct BLEWizardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var ble: BLEService

    enum WizardStep { case scan, credentials, monitor }
    enum WizardMode { case scan, manual }

    @State private var step: WizardStep = .scan
    @State private var mode: WizardMode = .scan

    @State private var primarySSID = ""
    @State private var primaryPassword = ""
    @State private var fallbackSSID = ""
    @State private var fallbackPassword = ""
    @State private var lotId = ""

    var body: some View {
        NavigationStack {
            VStack {
                if step != .monitor {
                    Picker("Mode", selection: $mode) {
                        Text("Scan").tag(WizardMode.scan)
                        Text("Manual / Debug").tag(WizardMode.manual)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }

                switch (mode, step) {
                case (.scan, .scan):
                    BLEScanStepView { peripheral in
                        ble.connect(to: peripheral)
                        step = .credentials
                    }
                case (.scan, .credentials), (.manual, _) where step == .credentials:
                    BLECredentialsStepView(
                        primarySSID: $primarySSID,
                        primaryPassword: $primaryPassword,
                        fallbackSSID: $fallbackSSID,
                        fallbackPassword: $fallbackPassword,
                        lotId: $lotId
                    ) {
                        pushCredentials()
                        if mode == .scan { step = .monitor }
                    }
                case (.manual, _):
                    BLECredentialsStepView(
                        primarySSID: $primarySSID,
                        primaryPassword: $primaryPassword,
                        fallbackSSID: $fallbackSSID,
                        fallbackPassword: $fallbackPassword,
                        lotId: $lotId
                    ) {
                        pushCredentials()
                    }
                case (_, .monitor):
                    BLEMonitorStepView { dismiss() }
                default:
                    EmptyView()
                }
            }
            .navigationTitle("Add Device")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        ble.disconnect()
                        dismiss()
                    }
                }
                if mode == .scan && step == .credentials {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Back") {
                            ble.disconnect()
                            step = .scan
                        }
                    }
                }
            }
        }
    }

    private func pushCredentials() {
        ble.writePrimary(ssid: primarySSID, password: primaryPassword)
        ble.writeFallback(ssid: fallbackSSID, password: fallbackPassword)
        ble.writeLotId(lotId)
        if mode == .scan { step = .monitor }
    }
}
