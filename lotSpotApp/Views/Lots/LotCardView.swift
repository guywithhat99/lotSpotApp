import SwiftUI

struct LotCardView: View {
    let lot: Lot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lot.name)
                    .font(.headline)
                Spacer()
                statusBadge
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(fillColor)
                        .frame(width: geo.size.width * lot.fillFraction)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(lot.occupancy) / \(lot.capacity)")
                    .font(.subheadline.monospacedDigit())
                Spacer()
                Text("\(lot.available) available")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(lastUpdatedText)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusBadge: some View {
        Text(lot.status == .open ? "Open" : "Closed")
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(lot.status == .open ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
            .foregroundStyle(lot.status == .open ? .green : .red)
            .clipShape(Capsule())
    }

    private var fillColor: Color {
        switch lot.fillFraction {
        case ..<0.7: return .green
        case ..<0.9: return .orange
        default: return .red
        }
    }

    private var lastUpdatedText: String {
        guard lot.lastUpdated > 0 else { return "Never updated" }
        let date = Date(timeIntervalSince1970: lot.lastUpdated)
        let mins = Int(Date().timeIntervalSince(date) / 60)
        if mins < 1 { return "Just updated" }
        return "Updated \(mins)m ago"
    }
}
