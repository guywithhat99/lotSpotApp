import SwiftUI

struct LotsListView: View {
    @EnvironmentObject var lots: LotService
    @State private var banner = ConnectionStatusBanner()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                banner

                if lots.lots.isEmpty {
                    ContentUnavailableView(
                        "No Lots",
                        systemImage: "car.2",
                        description: Text("No lots are configured yet.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(lots.lots) { lot in
                                NavigationLink(destination: LotDetailView(lotId: lot.id)) {
                                    LotCardView(lot: lot)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Lots")
            .onAppear {
                banner.startMonitoring()
            }
        }
    }
}
