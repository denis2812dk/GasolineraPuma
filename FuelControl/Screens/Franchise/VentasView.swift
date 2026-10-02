import SwiftUI
import Charts

struct VentasView: View {
    @State var viewModel: VentasViewModel
    var body: some View {
        List {
            Section("Ventas del día por combustible") {
                ForEach(viewModel.totals) { total in
                    HStack {
                        FuelChip(type: total.fuel)
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(total.revenue, format: .currency(code: "USD"))
                            Text(total.gallons, format: .number.precision(.fractionLength(2))) + Text(" gal")
                        }
                    }
                }
            }
            Section("Ventas por corte") {
                ForEach(viewModel.cortes) { corte in
                    NavigationLink {
                        CorteDetailView(viewModel: CorteDetailViewModel(sucursal: viewModel.sucursal, id: corte.id))
                    } label: {
                        VStack(alignment: .leading) {
                            Text(corte.turno.rawValue)
                            Text(viewModel.gallons(corte)).font(.headline)
                            Text(corte.closedAt == nil ? "Abierto · no consolidado en ventas del día" : "Cerrado")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }.navigationTitle("Ventas")
    }
}
