import SwiftUI

struct FranchiseDetailView: View {
    let franchiseId: String
    let onShiftSelect: (String) -> Void

    @State private var tab = 0

    private var franchise: Franchise {
        MockData.franchises.first { $0.id == franchiseId } ?? MockData.franchises[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.7))
                Text("Vista de franquicia · \(franchise.zone)")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                StatusBadge(franchiseStatus: franchise.status)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Theme.primary)

            TabView(selection: $tab) {
                InicioView().tag(0)
                    .tabItem { Label("Inicio", systemImage: "house.fill") }
                VentasView().tag(1)
                    .tabItem { Label("Ventas", systemImage: "chart.bar.fill") }
                TanquesView().tag(2)
                    .tabItem { Label("Tanques", systemImage: "drop.fill") }
                TurnosView(onShiftSelect: onShiftSelect).tag(3)
                    .tabItem { Label("Turnos", systemImage: "person.2.fill") }
            }
            .tint(Theme.primary)
        }
        .navigationTitle(franchise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        FranchiseDetailView(franchiseId: "f1", onShiftSelect: { _ in })
    }
}
