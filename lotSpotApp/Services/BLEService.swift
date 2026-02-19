import Foundation
import Combine
import CoreBluetooth

enum BLEConnectionState {
    case disconnected
    case connecting(name: String)
    case connected(name: String)
}

class BLEService: NSObject, ObservableObject {

    @Published var connectionState: BLEConnectionState = .disconnected
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var statusMessage: String = ""
    @Published var isScanning: Bool = false

    private var centralManager: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?
    private var characteristics: [CBUUID: CBCharacteristic] = [:]

    private var pendingWifiPrimary: Data?
    private var pendingWifiFallback: Data?
    private var pendingLotId: Data?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    // MARK: - Scanning

    func startScanning() {
        guard centralManager.state == .poweredOn else {
            statusMessage = "Bluetooth not available"
            return
        }
        discoveredPeripherals = []
        isScanning = true
        centralManager.scanForPeripherals(
            withServices: [BLEConstants.provisioningServiceUUID],
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        )
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }

    // MARK: - Connection

    func connect(to peripheral: CBPeripheral) {
        stopScanning()
        connectionState = .connecting(name: peripheral.name ?? peripheral.identifier.uuidString)
        connectedPeripheral = peripheral
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let p = connectedPeripheral {
            centralManager.cancelPeripheralConnection(p)
        }
    }

    // MARK: - Writing credentials

    func writePrimary(ssid: String, password: String) {
        pendingWifiPrimary = BLEConstants.encodeCredentials(ssid: ssid, password: password)
        write(data: pendingWifiPrimary!, to: BLEConstants.wifiPrimaryUUID)
    }

    func writeFallback(ssid: String, password: String) {
        pendingWifiFallback = BLEConstants.encodeCredentials(ssid: ssid, password: password)
        write(data: pendingWifiFallback!, to: BLEConstants.wifiFallbackUUID)
    }

    func writeLotId(_ lotId: String) {
        let data = BLEConstants.encodeLotId(lotId)
        pendingLotId = data
        write(data: data, to: BLEConstants.lotIdUUID)
    }

    func writeAll(primarySSID: String, primaryPassword: String,
                  fallbackSSID: String, fallbackPassword: String,
                  lotId: String) {
        writePrimary(ssid: primarySSID, password: primaryPassword)
        writeFallback(ssid: fallbackSSID, password: fallbackPassword)
        writeLotId(lotId)
    }

    private func write(data: Data, to uuid: CBUUID) {
        guard let peripheral = connectedPeripheral,
              let characteristic = characteristics[uuid] else {
            statusMessage = "Characteristic \(uuid) not found"
            return
        }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEService: CBCentralManagerDelegate {

    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor in
            if central.state != .poweredOn {
                statusMessage = "Bluetooth unavailable: \(central.state.rawValue)"
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didDiscover peripheral: CBPeripheral,
                                     advertisementData: [String: Any],
                                     rssi RSSI: NSNumber) {
        Task { @MainActor in
            if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                discoveredPeripherals.append(peripheral)
            }
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didConnect peripheral: CBPeripheral) {
        Task { @MainActor in
            connectionState = .connected(name: peripheral.name ?? peripheral.identifier.uuidString)
            peripheral.discoverServices([BLEConstants.provisioningServiceUUID])
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didDisconnectPeripheral peripheral: CBPeripheral,
                                     error: Error?) {
        Task { @MainActor in
            connectionState = .disconnected
            connectedPeripheral = nil
            characteristics = [:]
        }
    }

    nonisolated func centralManager(_ central: CBCentralManager,
                                     didFailToConnect peripheral: CBPeripheral,
                                     error: Error?) {
        Task { @MainActor in
            connectionState = .disconnected
            statusMessage = "Failed to connect: \(error?.localizedDescription ?? "unknown")"
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BLEService: CBPeripheralDelegate {

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services where service.uuid == BLEConstants.provisioningServiceUUID {
            peripheral.discoverCharacteristics(
                [BLEConstants.wifiPrimaryUUID,
                 BLEConstants.wifiFallbackUUID,
                 BLEConstants.lotIdUUID,
                 BLEConstants.statusUUID],
                for: service
            )
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didDiscoverCharacteristicsFor service: CBService,
                                 error: Error?) {
        guard let chars = service.characteristics else { return }
        Task { @MainActor in
            for char in chars {
                characteristics[char.uuid] = char
                if char.uuid == BLEConstants.statusUUID && char.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: char)
                }
            }
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didUpdateValueFor characteristic: CBCharacteristic,
                                 error: Error?) {
        guard characteristic.uuid == BLEConstants.statusUUID,
              let data = characteristic.value,
              let message = String(data: data, encoding: .utf8) else { return }
        Task { @MainActor in
            statusMessage = message
        }
    }

    nonisolated func peripheral(_ peripheral: CBPeripheral,
                                 didWriteValueFor characteristic: CBCharacteristic,
                                 error: Error?) {
        if let error {
            Task { @MainActor in
                statusMessage = "Write error: \(error.localizedDescription)"
            }
        }
    }
}
