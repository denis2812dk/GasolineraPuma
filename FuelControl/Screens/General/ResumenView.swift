import SwiftUI
import Charts

struct ResumenView: View {
    @State var viewModel: ResumenViewModel
    var body: some View {
        @Bindable var model = viewModel
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Red de estaciones").font(.title.bold())
                Picker("Panorama", selection: $model.selectedId) {
                    Text("Todo el país").tag("")
                    ForEach(viewModel.franchises) { station in
                        Text(station.name).tag(station.id)
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                    KPICard(title: "Ingresos del día", value: viewModel.revenue)
                    KPICard(title: "Galones del día", value: viewModel.gallons)
                    KPICard(title: "Estaciones", value: viewModel.stationCount)
                }
                ChartCardView(title: "Consumo por combustible") {
                    Chart(viewModel.totals) { total in
                        BarMark(x: .value("Combustible", total.fuel.label), y: .value("Galones", total.gallons))
                            .foregroundStyle(total.fuel.color)
                    }.frame(height: 170)
                    ForEach(viewModel.totals) { total in
                        HStack {
                            FuelChip(type: total.fuel)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(total.gallons, format: .number.precision(.fractionLength(2))) + Text(" gal")
                                Text(total.revenue, format: .currency(code: "USD"))
                            }
                        }
                    }
                }
                if !viewModel.selectedId.isEmpty {
                    NavigationLink("Ver sucursal seleccionada") {
                        FranchiseDetailView(viewModel: FranchiseDetailViewModel(general: viewModel.general, id: viewModel.selectedId))
                    }
                }
                Text("Top sucursales por galones").font(.headline)
                ForEach(viewModel.top) { station in
                    NavigationLink {
                        FranchiseDetailView(viewModel: FranchiseDetailViewModel(general: viewModel.general, id: station.id))
                    } label: {
                        HStack {
                            Text(station.name)
                            Spacer()
                            Text("\(station.dailyGallons) gal")
                            SparklineView(data: station.sparkline, color: Theme.ok)
                        }.padding().iosCard()
                    }
                }
                NavigationLink("Alertas de la red") {
                    AlertasListView(viewModel: AlertsViewModel(general: viewModel.general))
                }
                NavigationLink("Administración de estaciones y gerentes") {
                    AdministracionView(viewModel: AdministracionViewModel(general: viewModel.general))
                }
            }.padding()
        }
        .background(Theme.background)
        .navigationTitle("Resumen")
    }
}
