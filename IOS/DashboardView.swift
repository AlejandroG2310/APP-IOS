import SwiftUI

struct SidebarMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct DashboardView: View {
    var onLogout: () -> Void

    @State private var showMenu = false
    @State private var selectedMenu: String = "Dashboard"

    let menuWidth: CGFloat = 270
    let menuItems = [
        SidebarMenuItem(title: "Dashboard", icon: "house.fill"),
        SidebarMenuItem(title: "Perfil", icon: "person.crop.circle"),
        SidebarMenuItem(title: "Configuración", icon: "gearshape.fill"),
        SidebarMenuItem(title: "Reportes", icon: "doc.text.fill"),
    ]

    var body: some View {
        ZStack {
            // Contenido principal
            NavigationView {
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { withAnimation { showMenu = true } }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.blue)
                                .padding(.leading)
                        }
                        Spacer()
                        Text(selectedMenu)
                            .font(.headline)
                        Spacer()
                        // Avatar demo (puedes poner tu propio logo aquí)
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.trailing)
                    }
                    .frame(height: 50)
                    .background(Color.white.opacity(0.95))
                    .shadow(color: Color.gray.opacity(0.18), radius: 2, x: 0, y: 1)
                    
                    Group {
                        if selectedMenu == "Dashboard" {
                            VStack {
                                Spacer()
                                Text("¡Bienvenido al Dashboard!")
                                    .font(.largeTitle)
                                    .bold()
                                    .padding()
                                Spacer()
                            }
                        } else if selectedMenu == "Perfil" {
                            VStack {
                                Spacer()
                                Text("Vista Perfil")
                                    .font(.largeTitle)
                                    .padding()
                                Spacer()
                            }
                        } else if selectedMenu == "Configuración" {
                            VStack {
                                Spacer()
                                Text("Vista Configuración")
                                    .font(.largeTitle)
                                    .padding()
                                Spacer()
                            }
                        } else if selectedMenu == "Reportes" {
                            VStack {
                                Spacer()
                                Text("Vista Reportes")
                                    .font(.largeTitle)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
                }
            }
            .disabled(showMenu)
            .blur(radius: showMenu ? 3 : 0)
            
            // Fondo opaco al abrir menú lateral
            if showMenu {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation { showMenu = false }
                    }
            }
            
            // Sidebar realmente profesional
            HStack(spacing: 0) {
                if showMenu {
                    VStack(alignment: .leading, spacing: 12) {
                        // Header menú (avatar, nombre)
                        HStack {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 46))
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text("Usuario Demo")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("demo@email.com")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 18)

                        Divider()

                        // Items menú
                        ForEach(menuItems) { item in
                            Button(action: {
                                selectedMenu = item.title
                                withAnimation { showMenu = false }
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 22))
                                        .foregroundColor(.blue)
                                    Text(item.title)
                                        .font(.title3)
                                        .foregroundColor(selectedMenu == item.title ? .blue : .primary)
                                }
                                .padding(.vertical, 7)
                                .background(
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(selectedMenu == item.title ? Color.blue.opacity(0.12) : Color.clear)
                                )
                            }
                        }

                        Spacer()
                        Divider()

                        Button(action: {
                            UserDefaults.standard.removeObject(forKey: "authToken")
                            onLogout()
                            withAnimation { showMenu = false }
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 22))
                                    .foregroundColor(.red)
                                Text("Cerrar sesión")
                                    .font(.title3)
                                    .foregroundColor(.red)
                            }
                            .padding(.vertical, 7)
                        }
                        .padding(.bottom, 24)
                    }
                    .frame(width: menuWidth)
                    .padding(.horizontal, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.white, Color(.systemGray5)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(radius: 11)
                    .transition(.move(edge: .leading))
                    .gesture(
                        DragGesture().onChanged { value in
                            if value.translation.width < -80 {
                                withAnimation { showMenu = false }
                            }
                        }
                    )
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut, value: showMenu)
        }
    }
}