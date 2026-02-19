import SwiftUI

struct LotDetailView: View {
    let lotId: String
    @EnvironmentObject var lots: LotService
    @State private var errorMessage: String?

    private var lot: Lot? {
        lots.lots.first(where: { $0.id == lotId })
    }

    var body: some View {
        if let lot {
            Form {
                Section("Occupancy") {
                    LabeledContent("Current", value: "\(lot.occupancy) / \(lot.capacity)")
                    LabeledContent("Available", value: "\(lot.available)")
                    LabeledContent("Entries", value: "\(lot.totalEntries)")
                    LabeledContent("Exits", value: "\(lot.totalExits)")
                }

                Section {
                    HStack {
                        Button { adjustCount(lot: lot, delta: -1) } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(lot.occupancy <= 0)

                        Spacer()

                        Text("\(lot.occupancy)")
                            .font(.title.monospacedDigit())

                        Spacer()

                        Button { adjustCount(lot: lot, delta: 1) } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .disabled(lot.occupancy >= lot.capacity)
                    }
                    .padding(.vertical, 4)

                    Button("Reset to 0") { setCount(0) }
                        .disabled(lot.occupancy == 0)
                } header: {
                    Text("Manual Correction")
                } footer: {
                    Text("Correction persists until the next real vehicle event.")
                        .font(.caption)
                }

                Section("Lot Status") {
                    Toggle(
                        lot.status == .open ? "Lot is Open" : "Lot is Closed",
                        isOn: Binding(
                            get: { lot.status == .open },
                            set: { isOpen in toggleStatus(open: isOpen) }
                        )
                    )
                }

                if let error = errorMessage {
                    Section {
                        Text(error).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle(lot.name)
        } else {
            ContentUnavailableView("Lot Not Found", systemImage: "questionmark")
        }
    }

    private func adjustCount(lot: Lot, delta: Int) {
        let newCount = max(0, min(lot.capacity, lot.occupancy + delta))
        setCount(newCount)
    }

    private func setCount(_ count: Int) {
        Task {
            do {
                try await lots.setOccupancy(lotId: lotId, count: count)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func toggleStatus(open: Bool) {
        Task {
            do {
                try await lots.setStatus(lotId: lotId, status: open ? .open : .closed)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
