import SwiftUI
import FirebaseDatabase

struct ConnectionStatusBanner: View {
    @State private var isConnected = true
    @State private var lastUpdated: Date?

    var body: some View {
        if !isConnected {
            HStack {
                Image(systemName: "wifi.slash")
                Text(lastUpdatedText)
                    .font(.caption)
            }
            .foregroundStyle(.white)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(Color.red)
        }
    }

    private var lastUpdatedText: String {
        guard let date = lastUpdated else { return "Backend offline" }
        let mins = Int(Date().timeIntervalSince(date) / 60)
        return "Backend offline — last updated \(mins)m ago"
    }

    func startMonitoring() {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value) { snapshot in
            isConnected = snapshot.value as? Bool ?? false
            if isConnected { lastUpdated = Date() }
        }
    }
}
