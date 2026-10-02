import SwiftUI

struct CortesView: View {
    @State var viewModel: CortesViewModel
    var body: some View {
        List {
            Section("Dos cortes diarios") {
                ForEach(viewModel.cortes) { corte in
                    NavigationLink {
                        CorteDetailView(viewModel: CorteDetailViewModel(sucursal: viewModel.sucursal, id: corte.id))
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(corte.turno.rawValue).font(.headline)
                            Text(corte.day, style: .date)
                            Text(corte.closedAt == nil ? "Abierto" : "Cerrado · Solo lectura")
                                .foregroundStyle(corte.closedAt == nil ? Theme.primary : Theme.ok)
                        }
                    }
                }
            }
            Text("Registra las seis bombas en cada corte. Introduce 0 en las categorías sin movimientos.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .navigationTitle("Cortes")
        .onAppear { viewModel.refresh() }
    }
}
