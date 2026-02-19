import SwiftUI
import Combine
import FirebaseAuth
import FirebaseDatabase

class AppEnvironment: ObservableObject {
    let auth: AuthService
    let lots: LotService
    let devices: DeviceService
    let ble: BLEService

    init() {
        self.auth = AuthService()
        self.lots = LotService()
        self.devices = DeviceService()
        self.ble = BLEService()
    }
}
