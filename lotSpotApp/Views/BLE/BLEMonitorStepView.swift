import SwiftUI

struct BLEMonitorStepView: View {
    @EnvironmentObject var ble: BLEService
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Circle()
                .fill(dotColor)
                .frame(width: 60, height: 60)
                .scaleEffect(isPulsing ? 1.15 : 1.0)
                .animation(
                    isPulsing ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                    value: isPulsing
                )

            Text(ble.statusMessage.isEmpty ? "Waiting for device…" : ble.statusMessage)
                .font(.headline)

            Text(explanationText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            if ble.statusMessage.hasPrefix("connected") {
                Button("Done") { onDone() }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding()
            }

            if ble.statusMessage.hasPrefix("error") {
                Button("Try Again") { onDone() }
                    .buttonStyle(.bordered)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .padding()
    }

    private var dotColor: Color {
        switch ble.statusMessage {
        case let s where s.hasPrefix("connected"): return .green
        case let s where s.hasPrefix("connecting"): return .blue
        case let s where s.hasPrefix("error"): return .red
        default: return .yellow
        }
    }

    private var isPulsing: Bool {
        !ble.statusMessage.hasPrefix("connected") && !ble.statusMessage.hasPrefix("error")
    }

    private var explanationText: String {
        switch ble.statusMessage {
        case let s where s.hasPrefix("scanning"): return "Device is scanning for WiFi network."
        case let s where s.hasPrefix("connecting"): return "Device is connecting to WiFi."
        case let s where s.hasPrefix("connected"): return "Device is online and connected."
        case let s where s.hasPrefix("error"): return "Connection failed. Check credentials and try again."
        default: return "Waiting for device status…"
        }
    }
}
