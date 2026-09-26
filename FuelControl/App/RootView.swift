import SwiftUI

struct RootView: View {
    @State private var role: UserRole?

    var body: some View {
        Group {
            switch role {
            case .none:
                LoginView(onLogin: { role = $0 })
            case .franchise:
                FranchiseTabView()
            case .general:
                GeneralTabView(onLogout: { role = nil })
            }
        }
    }
}

#Preview {
    RootView()
}
