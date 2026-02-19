import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @EnvironmentObject var auth: AuthService

    var body: some View {
        TabView {
            LotsListView()
                .tabItem {
                    Label("Lots", systemImage: "car.2.fill")
                }

            if auth.role == .admin {
                DevicesListView()
                    .tabItem {
                        Label("Devices", systemImage: "cpu")
                    }
            }

            settingsTab
        }
    }

    private var settingsTab: some View {
        NavigationStack {
            Form {
                Section {
                    Button("Sign Out", role: .destructive) {
                        try? auth.signOut()
                    }
                }
                Section("Account") {
                    LabeledContent("Role", value: auth.role.rawValue.capitalized)
                    LabeledContent("Email", value: auth.currentUser?.email ?? "—")
                }
            }
            .navigationTitle("Settings")
        }
        .tabItem {
            Label("Settings", systemImage: "gear")
        }
    }
}
