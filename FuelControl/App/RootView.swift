import SwiftUI

struct RootView: View {
    @State private var session = SessionViewModel()
    @State private var general = GeneralViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch session.role {
            case .none:
                LoginView(onLogin: attemptLogin)
            case .general:
                GeneralTabView(general: general, accountName: session.accountName,
                                accountEmail: session.accountEmail, onLogout: session.logout)
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

    private func attemptLogin(email: String, password: String) -> String? {
        if general.authenticateGeneral(email: email, password: password) {
            session.login(role: .general, name: general.generalAccount.name, email: general.generalAccount.email)
            return nil
        }
        if let match = general.authenticateFranchise(email: email, password: password) {
            session.login(role: .franchise, franchiseId: match.stationId, name: match.name, email: email)
            return nil
        }
        return "Correo o contraseña incorrectos."
    }
}

#Preview { RootView() }
