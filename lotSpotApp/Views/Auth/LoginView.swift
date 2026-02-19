import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 24) {
            Text("LotSpot")
                .font(.largeTitle.bold())

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button(action: signIn) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty || isLoading)
        }
        .padding(32)
    }

    private func signIn() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                try await auth.signIn(email: email, password: password)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
