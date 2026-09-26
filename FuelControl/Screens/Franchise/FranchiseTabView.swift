import SwiftUI

struct FranchiseTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                InicioView()
                    .navigationTitle("Inicio")
            }
            .tabItem { Label("Inicio", systemImage: "house.fill") }

            NavigationStack {
                VentasView()
                    .navigationTitle("Ventas")
            }
            .tabItem { Label("Ventas", systemImage: "chart.bar.fill") }

            NavigationStack {
                TanquesView()
                    .navigationTitle("Tanques")
            }
            .tabItem { Label("Tanques", systemImage: "drop.fill") }

            FranchiseTurnosTab()
                .tabItem { Label("Turnos", systemImage: "person.2.fill") }

            NavigationStack {
                AlertasListView(alerts: MockData.franchiseAlerts)
                    .navigationTitle("Alertas")
            }
            .tabItem { Label("Alertas", systemImage: "bell.fill") }
        }
        .tint(Theme.primary)
    }
}

/// Franchise "Turnos" tab wired with real navigation to the shift detail screen.
/// Kept separate from `TurnosView` so the tab can own its own `NavigationStack` path.
struct FranchiseTurnosTab: View {
    @State private var path: [String] = []

    var body: some View {
        NavigationStack(path: $path) {
            TurnosView(onShiftSelect: { id in path.append(id) })
                .navigationTitle("Turnos")
                .navigationDestination(for: String.self) { shiftId in
                    if let shift = MockData.shifts.first(where: { $0.id == shiftId }) {
                        ShiftDetailView(shift: shift)
                    }
                }
        }
    }
}

#Preview {
    FranchiseTabView()
}
