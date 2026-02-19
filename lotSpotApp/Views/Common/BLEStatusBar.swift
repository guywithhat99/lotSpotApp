import SwiftUI

struct BLEStatusBar: View {
    @EnvironmentObject var ble: BLEService

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(dotColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
    }

    private var dotColor: Color {
        switch ble.connectionState {
        case .connected: return .green
        case .connecting: return .yellow
        case .disconnected: return Color(.systemGray3)
        }
    }

    private var statusText: String {
        switch ble.connectionState {
        case .connected(let name): return "Connected to \(name)"
        case .connecting(let name): return "Connecting to \(name)…"
        case .disconnected: return "No device connected"
        }
    }
}
