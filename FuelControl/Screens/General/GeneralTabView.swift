import SwiftUI

struct GeneralTabView: View {
    let general: GeneralViewModel
    let accountName: String
    let accountEmail: String
    let onLogout: () -> Void

    var body: some View {
        TabView {
            NavigationStack {
                ResumenView(viewModel: ResumenViewModel(general: general))
            }
            .tabItem { Label("Resumen", systemImage: "square.grid.2x2.fill") }
            NavigationStack {
                FranquiciasView(viewModel: FranquiciasViewModel(general: general),
                                onFranchiseSelect: { selectedId = $0 })
                    .navigationDestination(item: $selectedId) { id in
                        FranchiseDetailView(viewModel: FranchiseDetailViewModel(general: general, id: id))
                    }
            }
            .tabItem { Label("Franquicias", systemImage: "map.fill") }
            NavigationStack {
                CompararView(viewModel: CompararViewModel(general: general))
            }
            .tabItem { Label("Comparar", systemImage: "arrow.left.arrow.right") }
            NavigationStack {
                AdministracionView(viewModel: AdministracionViewModel(general: general))
            }
            .tabItem { Label("Administración", systemImage: "building.2.crop.circle") }
            NavigationStack {
                PerfilView(name: accountName, email: accountEmail, onLogout: onLogout)
            }
            .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
    @State private var selectedId: String?
}
