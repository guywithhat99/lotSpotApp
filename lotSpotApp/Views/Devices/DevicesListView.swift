import SwiftUI

struct DevicesListView: View {
    @EnvironmentObject var devices: DeviceService
    @EnvironmentObject var ble: BLEService
    @State private var showingWizard = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BLEStatusBar()

                List(devices.devices) { device in
                    NavigationLink(destination: DeviceDetailView(device: device)) {
                        HStack {
                            Circle()
                                .fill(device.status == .online ? Color.green : Color(.systemGray3))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading) {
                                Text(device.id).font(.headline)
                                Text(device.lotId).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(device.status.rawValue.capitalized)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Devices")
            .toolbar {
                Button {
                    showingWizard = true
                } label: {
                    Label("Add Device", systemImage: "plus")
                }
            }
            .fullScreenCover(isPresented: $showingWizard) {
                BLEWizardView()
            }


        }
    }
}
