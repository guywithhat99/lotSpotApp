import Foundation
import Combine
import FirebaseAuth
import FirebaseDatabase

class AuthService: ObservableObject {
    @Published var currentUser: User?
    @Published var role: UserRole = .unknown
    @Published var isLoggedIn: Bool = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isLoggedIn = user != nil
                if let uid = user?.uid {
                    await self?.fetchRole(uid: uid)
                } else {
                    self?.role = .unknown
                }
            }
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    private func fetchRole(uid: String) async {
        let ref = Database.database().reference().child("users/\(uid)/role")
        do {
            let snapshot = try await ref.getData()
            let raw = snapshot.value as? String ?? "attendant"
            self.role = UserRole(rawValue: raw) ?? .attendant
        } catch {
            self.role = .attendant
        }
    }
}
