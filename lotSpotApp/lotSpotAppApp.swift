import SwiftUI
import FirebaseCore

@main
struct lotSpotAppApp: App {
    @StateObject private var env = AppEnvironment()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(env.auth)
                .environmentObject(env.lots)
                .environmentObject(env.devices)
                .environmentObject(env.ble)
        }
    }
}
