import CoreBluetooth

// TODO: Replace placeholder UUIDs with finalized values from the hardware team.
enum BLEConstants {

    // MARK: - Service

    static let provisioningServiceUUID = CBUUID(string: "12345678-1234-1234-1234-123456789001")

    // MARK: - Characteristics

    /// Write: "SSID\nPASSWORD" (UTF-8)
    static let wifiPrimaryUUID = CBUUID(string: "12345678-1234-1234-1234-123456789002")

    /// Write: "SSID\nPASSWORD" (UTF-8)
    static let wifiFallbackUUID = CBUUID(string: "12345678-1234-1234-1234-123456789003")

    /// Write: "lot-a" (UTF-8)
    static let lotIdUUID = CBUUID(string: "12345678-1234-1234-1234-123456789004")

    /// Notify: "scanning" | "connecting" | "connected" | "error:<message>" (UTF-8)
    static let statusUUID = CBUUID(string: "12345678-1234-1234-1234-123456789005")

    // MARK: - Payload helpers

    static func encodeCredentials(ssid: String, password: String) -> Data {
        "\(ssid)\n\(password)".data(using: .utf8) ?? Data()
    }

    static func encodeLotId(_ lotId: String) -> Data {
        lotId.data(using: .utf8) ?? Data()
    }
}
