import SwiftUI

/// Shared route type so a franchise drill-down can push a shift detail
/// on top of itself within the same tab's navigation stack.
enum GeneralRoute: Hashable {
    case franchise(String)
    case shift(String)
}

struct GeneralTabView: View {
    let onLogout: () -> Void

    var body: some View {
        TabView {
            GeneralRouterStack { path in
                ResumenView(onFranchiseSelect: { path.wrappedValue.append(.franchise($0)) })
                    .navigationTitle("Resumen")
            }
            .tabItem { Label("Resumen", systemImage: "square.grid.2x2.fill") }

            GeneralRouterStack { path in
                FranquiciasView(onFranchiseSelect: { path.wrappedValue.append(.franchise($0)) })
                    .navigationTitle("Franquicias")
            }
            .tabItem { Label("Franquicias", systemImage: "map.fill") }

            NavigationStack {
                CompararView()
                    .navigationTitle("Comparar")
            }
            .tabItem { Label("Comparar", systemImage: "arrow.left.arrow.right") }

            NavigationStack {
                AlertasListView(alerts: MockData.generalAlerts)
                    .navigationTitle("Alertas")
            }
            .tabItem { Label("Alertas", systemImage: "bell.fill") }

            NavigationStack {
                PerfilView(onLogout: onLogout)
                    .navigationTitle("Perfil")
            }
            .tabItem { Label("Perfil", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
}

/// A `NavigationStack` that knows how to push `GeneralRoute` values
/// (a franchise drill-down, and from there a shift detail).
private struct GeneralRouterStack<Root: View>: View {
    @ViewBuilder var root: (Binding<[GeneralRoute]>) -> Root

    @State private var path: [GeneralRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            root($path)
                .navigationDestination(for: GeneralRoute.self) { route in
                    switch route {
                    case .franchise(let id):
                        FranchiseDetailView(
                            franchiseId: id,
                            onShiftSelect: { path.append(.shift($0)) }
                        )
                    case .shift(let id):
                        if let shift = MockData.shifts.first(where: { $0.id == id }) {
                            ShiftDetailView(shift: shift)
                        }
                    }
                }
        }
    }
}

#Preview {
    GeneralTabView(onLogout: {})
}
