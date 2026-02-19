import SwiftUI

struct RootView: View {
    @EnvironmentObject var auth: AuthService
    @EnvironmentObject var lots: LotService
    @EnvironmentObject var devices: DeviceService

    var body: some View {
        if auth.isLoggedIn {
            MainTabView()
                .onAppear {
                    lots.startObserving()
                    devices.startObserving()
                }
        } else {
            LoginView()
        }
    }
}
