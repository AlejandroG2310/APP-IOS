import SwiftUI

struct LoginView: View {
    var onLogin: (String) -> Void
    @State private var username = ""
    @State private var password = ""
    @State private var loginError: String?
    @State private var isLoading = false
    @State private var isLoggedIn = false
    @State private var showPassword = false
    @State private var goToDashboard = false

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 32) {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                    
                    Text("Bienvenido")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                    
                    VStack(spacing: 16) {
                        TextField("Usuario", text: $username)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 2)
                            )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        ZStack(alignment: .trailing) {
                            Group {
                                if showPassword {
                                    TextField("Contraseña", text: $password)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 12 + 34)
                                        .autocapitalization(.none)
                                } else {
                                    SecureField("Contraseña", text: $password)
                                        .padding(.vertical, 14)
                                        .padding(.horizontal, 12 + 34)
                                        .autocapitalization(.none)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.85))
                                    .shadow(color: Color.gray.opacity(0.15), radius: 3, x: 0, y: 2)
                            )
                            .disableAutocorrection(true)
                            
                            Button(action: {
                                showPassword.toggle()
                            }) {
                                Circle()
                                    .fill(Color.gray.opacity(0.20))
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Image(systemName: showPassword ? "eye" : "eye.slash")
                                            .foregroundColor(showPassword ? .blue : .gray)
                                            .font(.system(size: 16, weight: .semibold))
                                    )
                                    .shadow(color: Color.gray.opacity(0.08), radius: 2, x: 0, y: 1)
                            }
                            .padding(.trailing, 12)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .bold()
                            .padding(.top, -20)
                            .transition(.opacity)
                    }
                    
                    Button(action: {
                        isLoading = true
                        loginError = nil
                        login(username: username, password: password)
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text("Ingresar")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: Color.purple.opacity(0.2), radius: 8, y: 6)
                    }
                    .disabled(isLoading || username.isEmpty || password.isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    if isLoggedIn {
                        Text("¡Login exitoso!")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)
                
                NavigationLink(
                    destination: DashboardView(onLogout: {}),
                    isActive: $goToDashboard,
                    label: { EmptyView() }
                )
            }
        }
    }
    
    func login(username: String, password: String) {
        print("🔵 Intentando login con usuario:", username)
        guard let url = URL(string: "\(AppConfig.apiBase)/auth/login") else {
            print("❌ URL inválida")
            loginError = "URL inválida"
            isLoading = false
            return
        }
        print("🌐 URL:", url)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: String] = [
            "username": username,
            "password": password
        ]
        print("📦 Payload:", payload)
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error request:", error.localizedDescription)
            }
            if let response = response as? HTTPURLResponse {
                print("📡 Status Code:", response.statusCode)
            }
            if let data = data {
                print("📥 Response data:", String(data: data, encoding: .utf8) ?? "No readable data")
            }
            DispatchQueue.main.async {
                isLoading = false
                guard error == nil else {
                    loginError = error!.localizedDescription
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    loginError = "Respuesta inválida"
                    return
                }
                guard httpResponse.statusCode == 200 else {
                    loginError = "Usuario o contraseña incorrectos"
                    return
                }
                if let data = data,
                   let result = try? JSONDecoder().decode(TokenResponse.self, from: data),
                   let token = result.access_token {
                    print("✅ Login exitoso, token:", token)
                    isLoggedIn = true
                    goToDashboard = true
                    onLogin(token)
                } else {
                    loginError = "Respuesta inesperada del servidor"
                }
            }
        }.resume()
    }
}