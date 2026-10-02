import SwiftUI

struct RootView: View {
    @State private var session = SessionViewModel()
    @State private var general = GeneralViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch session.role {
            case .none:
                LoginView(onLogin: session.login)
            case .general:
                GeneralTabView(general: general, onLogout: session.logout)
            case .franchise:
                if let sucursal = general.sucursales[session.franchiseId] {
                    FranchiseTabView(general: general, sucursal: sucursal, onLogout: session.logout)
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { general.refreshDay() }
        }
        .task {
            while !Task.isCancelled {
                general.refreshDay()
                do { try await Task.sleep(for: .seconds(30)) }
                catch { break }
            }
        }
    }
}

#Preview { RootView() }
