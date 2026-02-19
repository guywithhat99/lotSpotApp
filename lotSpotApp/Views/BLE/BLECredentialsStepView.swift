import SwiftUI

struct BLECredentialsStepView: View {
    @Binding var primarySSID: String
    @Binding var primaryPassword: String
    @Binding var fallbackSSID: String
    @Binding var fallbackPassword: String
    @Binding var lotId: String
    let onSubmit: () -> Void

    var body: some View {
        Form {
            Section {
                TextField("Hotspot SSID", text: $primarySSID)
                    .autocapitalization(.none)
                SecureField("Hotspot Password", text: $primaryPassword)
            } header: {
                Text("Primary WiFi (Hotspot)")
            } footer: {
                Text("Usually your iPhone's personal hotspot.")
            }

            Section {
                TextField("Fallback SSID", text: $fallbackSSID)
                    .autocapitalization(.none)
                SecureField("Fallback Password", text: $fallbackPassword)
            } header: {
                Text("Fallback WiFi")
            } footer: {
                Text("Venue WiFi or backup network.")
            }

            Section("Lot Assignment") {
                TextField("Lot ID (e.g. lot-a)", text: $lotId)
                    .autocapitalization(.none)
            }

            Button("Push to Device") { onSubmit() }
                .frame(maxWidth: .infinity)
                .disabled(primarySSID.isEmpty || primaryPassword.isEmpty || lotId.isEmpty)
                .buttonStyle(.borderedProminent)
        }
    }
}
