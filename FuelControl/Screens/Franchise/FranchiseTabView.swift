import SwiftUI

struct FranchiseTabView: View {
    let general: GeneralViewModel
    let sucursal: SucursalViewModel
    var onLogout: (() -> Void)?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            NavigationStack {
                InicioView(viewModel: InicioViewModel(general: general, sucursal: sucursal))
                    .toolbar {
                        if let onLogout {
                            Button("Cerrar sesión", action: onLogout)
                        }
                    }
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }
            NavigationStack {
                VentasView(viewModel: VentasViewModel(general: general, sucursal: sucursal))
            }
            .tabItem { Label("Ventas", systemImage: "chart.bar.fill") }
            NavigationStack {
                TanquesView(viewModel: TanquesViewModel(sucursal: sucursal))
            }
            .tabItem { Label("Tanques", systemImage: "drop.fill") }
            NavigationStack {
                CortesView(viewModel: CortesViewModel(sucursal: sucursal))
            }
            .tabItem { Label("Cortes", systemImage: "doc.text.fill") }
            NavigationStack {
                AlertasListView(viewModel: AlertsViewModel(general: general, sucursal: sucursal))
            }
            .tabItem { Label("Alertas", systemImage: "bell.fill") }
        }
        .tint(Theme.primary)
        .onAppear { sucursal.ensureToday() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { sucursal.ensureToday() }
        }
    }
}
