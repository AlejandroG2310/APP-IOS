import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "authToken") != nil

    var body: some View {
        if isLoggedIn {
            DashboardView(onLogout: {
                isLoggedIn = false
            })
        } else {
            LoginView(onLogin: { token in
                UserDefaults.standard.set(token, forKey: "authToken")
                isLoggedIn = true
            })
        }
    }
}